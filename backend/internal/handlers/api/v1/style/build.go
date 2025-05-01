package style

import (
	"errors"
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

type StyleBuildResult struct {
	StyleId string `json:"style_id" validate:"required"`
}

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

	if styleId != "" {
		response := StyleBuildResult{
			StyleId: styleId,
		}

		return ctx.JSON(http.StatusOK, response)
	}

	photo, err := ctx.FormFile("photo")
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
	}

	src, err := photo.Open()
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
	}
	defer src.Close()

	fileKey := photo.Filename

	payment, err := ctr.storage.Payments.Get(parsedUserId)

	if err != nil || payment == nil || payment.Status != models.Paid {
		ctr.logger.Error("Не оплачено")
		return myerrors.GetHttpErrorByCode(myerrors.NotPaid, ctx)
	}

	_, err = ctr.s3Client.PutObject(&s3.PutObjectInput{
		Bucket:      aws.String(ctr.config.StylePhotoBucket),
		Key:         aws.String(fmt.Sprintf("%s/%s", parsedUserId.String(), fileKey)),
		Body:        src,
		ContentType: aws.String(photo.Header.Get("Content-Type")),
	})
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.ExternalError, ctx)
	}

	photoURL := fmt.Sprintf("%s/%s/%s/%s", ctr.config.MinioFilePathEndpoint, ctr.config.StylePhotoBucket, parsedUserId.String(), fileKey)

	ctr.logger.Info(photoURL)

	styleId = external.GetStyle()

	userStyle := &models.DbUserStyle{
		UserId:   parsedUserId,
		PhotoUrl: photoURL,
		StyleId:  styleId,
	}

	ctr.storage.UserStyle.Create(userStyle)

	external.UpdateLeadStatus(ctr.config, ctr.logger, user.AmocrmLeadId, external.GotStyle, &styleId)

	return ctx.JSON(http.StatusOK, StyleBuildResult{
		StyleId: styleId,
	})
}
