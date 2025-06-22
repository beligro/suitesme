package style

import (
	"net/http"
	"suitesme/internal/models"
	"suitesme/pkg/myerrors"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type StyleInfo struct {
	StyleId         string `json:"style_id"`
	CanUploadPhotos bool   `json:"can_upload_photos"`
}

func (ctr StyleController) Info(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	userID := ctx.Get("userID")
	if userID == nil {
		return myerrors.GetHttpErrorByCode(myerrors.UserUnauthorized, ctx)
	}

	parsedUserId := userID.(uuid.UUID)

	styleId, err := ctr.storage.UserStyle.Get(parsedUserId)

	if err != nil && err != gorm.ErrRecordNotFound {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Get user to check if admin
	user, err := ctr.storage.User.Get(parsedUserId)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Admin users can always upload photos
	canUploadPhotos := user.IsAdmin

	if styleId != "" {
		response := StyleInfo{
			StyleId:         styleId,
			CanUploadPhotos: canUploadPhotos,
		}

		return ctx.JSON(http.StatusOK, response)
	}

	// If not admin, check payment
	if !canUploadPhotos {
		payment, err := ctr.storage.Payments.Get(parsedUserId)
		if err != nil || payment == nil || payment.Status != models.Paid {
			ctr.logger.Error("Не оплачено")
			return myerrors.GetHttpErrorByCode(myerrors.NotPaid, ctx)
		}
		// Regular users with payment can upload one photo
		canUploadPhotos = true
	}

	return myerrors.GetHttpErrorByCode(myerrors.StyleNotFound, ctx)
}
