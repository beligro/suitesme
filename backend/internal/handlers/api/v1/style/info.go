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
	StyleId string `json:"style_id"`
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

	payment := ctr.storage.Payments.Get(parsedUserId)

	if payment == nil || payment.Status != models.Paid {
		ctr.logger.Error("Не оплачено")
		return myerrors.GetHttpErrorByCode(http.StatusForbidden)
	}

	return myerrors.GetHttpErrorByCode(http.StatusNotFound)
}
