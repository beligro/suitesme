package style

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"suitesme/internal/models"
	"suitesme/internal/utils/external"
	"suitesme/pkg/myerrors"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type StyleBuildResult struct {
	StyleId string `json:"style_id" validate:"required"`
	Warning string `json:"warning,omitempty"`
}

// Build godoc
// @Summary Upload user photos and determine style
// @Description Upload user photos (1-4), save them to S3, and determine user's style using ML service
// @Tags style
// @Accept multipart/form-data
// @Produce json
// @Param Authorization header string true "Bearer token"
// @Param photos formData file true "User photos (1-4 images)"
// @Success 200 {object} StyleBuildResult
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 403 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/v1/style/build [post]
func (ctr StyleController) Build(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	userID := ctx.Get("userID")
	if userID == nil {
		return myerrors.GetHttpErrorByCode(myerrors.UserUnauthorized, ctx)
	}

	parsedUserId := userID.(uuid.UUID)

	user, err := ctr.storage.User.Get(parsedUserId)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		ctr.logger.Warn("User not found")
		return myerrors.GetHttpErrorByCode(myerrors.UserNotFound, ctx)
	}
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}
	if user == nil {
		return myerrors.GetHttpErrorByCode(myerrors.UserNotFound, ctx)
	}

	styleId, err := ctr.storage.UserStyle.Get(parsedUserId)

	if err != nil && err != gorm.ErrRecordNotFound {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Regular users can only upload once
	if styleId != "" && !user.IsAdmin {
		response := StyleBuildResult{
			StyleId: styleId,
		}

		return ctx.JSON(http.StatusOK, response)
	}

	// Parse multipart form
	form, err := ctx.MultipartForm()
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
	}

	photos := form.File["photos"]
	if len(photos) < 1 || len(photos) > 4 {
		ctr.logger.Error(fmt.Sprintf("Invalid number of photos: %d (must be 1-4)", len(photos)))
		return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
	}

	// Check if user is admin
	if !user.IsAdmin {
		// If not admin, check payment
		payment, err := ctr.storage.Payments.Get(parsedUserId)
		if err != nil || payment == nil || payment.Status != models.Paid {
			ctr.logger.Error("Не оплачено")
			return myerrors.GetHttpErrorByCode(myerrors.NotPaid, ctx)
		}
	}

	// Read all photo data and upload to S3
	photosData := make([][]byte, len(photos))
	photoURLs := make([]string, len(photos))

	for i, photo := range photos {
		src, err := photo.Open()
		if err != nil {
			ctr.logger.Error(err)
			return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
		}

		// Read photo data
		photoData, err := io.ReadAll(src)
		src.Close()
		if err != nil {
			ctr.logger.Error(err)
			return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
		}

		photosData[i] = photoData

		// Upload to S3
		fileKey := fmt.Sprintf("%s/%s", parsedUserId.String(), photo.Filename)
		_, err = ctr.s3Client.PutObject(&s3.PutObjectInput{
			Bucket:      aws.String(ctr.config.StylePhotoBucket),
			Key:         aws.String(fileKey),
			Body:        bytes.NewReader(photoData),
			ContentType: aws.String(photo.Header.Get("Content-Type")),
		})
		if err != nil {
			ctr.logger.Error(err)
			return myerrors.GetHttpErrorByCode(myerrors.ExternalError, ctx)
		}

		// Use relative URL path to avoid hardcoding server IP
		photoURLs[i] = fmt.Sprintf("/files/%s/%s/%s", ctr.config.StylePhotoBucket, parsedUserId.String(), photo.Filename)
	}

	// Use first photo URL for user style record (main photo)
	photoURL := photoURLs[0]

	// Send all photos to ML service
	styleId, confidence, imagesProcessed, imagesTotal, err := external.GetStyle(photosData)
	if err != nil {
		ctr.logger.Error("Failed to get style from ML service:", err)
		// Check if the error is about no face detected
		if err.Error() == "no face detected in the photo" {
			return myerrors.GetHttpErrorByCode(myerrors.NoFaceDetected, ctx)
		}
		return myerrors.GetHttpErrorByCode(myerrors.ExternalError, ctx)
	}
	
	// Debug logging
	ctr.logger.Info(fmt.Sprintf("ML Response - StyleId: %s, Confidence: %.2f, ImagesProcessed: %d, ImagesTotal: %d", 
		styleId, confidence, imagesProcessed, imagesTotal))

	// Store all photo URLs
	photoURLsJSON, _ := json.Marshal(photoURLs)
	
	userStyle := &models.DbUserStyle{
		UserId:            parsedUserId,
		PhotoUrl:          photoURL,
		PhotoUrls:         photoURLsJSON,
		StyleId:           styleId,
		InitialPrediction: styleId,
		Confidence:        confidence,
	}

	ctr.storage.UserStyle.Create(userStyle)

	external.UpdateLeadStatus(ctr.config, ctr.logger, user.AmocrmLeadId, external.GotStyle, &styleId)

	// Construct warning message if some photos didn't have faces
	var warningMessage string
	if imagesProcessed < imagesTotal {
		failedCount := imagesTotal - imagesProcessed
		if imagesTotal == 1 {
			// Single photo with no face (shouldn't reach here, but for safety)
			warningMessage = "На фотографии нет лица, загрузите другое фото"
		} else if imagesProcessed == 0 {
			// All photos failed (shouldn't reach here, but for safety)
			warningMessage = "На фотографиях нет лиц, загрузите другие фото"
		} else {
			// Partial success
			processedWord := "фотографии"
			if imagesProcessed == 1 {
				processedWord = "фотографии"
			} else if imagesProcessed >= 2 && imagesProcessed <= 4 {
				processedWord = "фотографий"
			}
			
			failedWord := "не содержит"
			if failedCount > 1 {
				failedWord = "не содержат"
			}
			
			failedPhrase := fmt.Sprintf("%d", failedCount)
			if failedCount == 1 {
				failedPhrase = "1"
			}
			
			warningMessage = fmt.Sprintf("Предсказание сделано на основе %d %s, %s %s лица", 
				imagesProcessed, processedWord, failedPhrase, failedWord)
		}
	}

	response := StyleBuildResult{
		StyleId: styleId,
		Warning: warningMessage,
	}

	return ctx.JSON(http.StatusOK, response)
}
