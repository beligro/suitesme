package style

import (
	"fmt"
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

type StyleInfo struct {
	StyleId string `json:"style_id" validate:"required"`
}

func (ctr StyleController) Info(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	userID := ctx.Get("userID")
	if userID == nil {
		return myerrors.GetHttpErrorByCode(http.StatusUnauthorized)
	}

	parsedUserId := userID.(uuid.UUID)

	styleId, err := ctr.storage.UserStyle.Get(parsedUserId)

	if err != nil && err != gorm.ErrRecordNotFound {
		ctr.logger.Error(err)
		return myerrors.ParseGormErrorToHttp(err)
	}

	if styleId != "" {
		response := StyleInfo{
			StyleId: styleId,
		}

		return ctx.JSON(http.StatusOK, response)
	}

	photo, err := ctx.FormFile("photo")
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	src, err := photo.Open()
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}
	defer src.Close()

	fileKey := photo.Filename

	// TODO: check payment

	_, err = ctr.s3Client.PutObject(&s3.PutObjectInput{
		Bucket:      aws.String(ctr.config.StylePhotoBucket),
		Key:         aws.String(fmt.Sprintf("%s/%s", parsedUserId.String(), fileKey)),
		Body:        src,
		ContentType: aws.String(photo.Header.Get("Content-Type")),
	})
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusInternalServerError)
	}

	photoURL := fmt.Sprintf("%s/%s/%s/%s", ctr.config.MinioFilePathEndpoint, ctr.config.StylePhotoBucket, parsedUserId.String(), fileKey)

	ctr.logger.Info(photoURL)

	styleId = external.GetStyle()

	userStyle := &models.DbUserStyle{
		UserId:   parsedUserId,
		PhotoUrl: photoURL,
		StyleId:  styleId,
	}

	err = ctr.storage.UserStyle.Create(userStyle)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.ParseGormErrorToHttp(err)
	}

	return ctx.JSON(http.StatusOK, StyleInfo{
		StyleId: styleId,
	})
}
