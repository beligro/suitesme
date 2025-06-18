package payment

import (
	"errors"
	"net/http"
	"suitesme/pkg/myerrors"
	"time"

	"suitesme/internal/models"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type PaymentInfoResponse struct {
	Status models.PaymentStatus `json:"payment_status" validate:"required"`
}

// @Summary		Get payment info
// @Description	Get payment-info
// @ID			get-payment-info
// @Accept		json
// @Produce		json
// @Tags		payment
// @Param		Authorization	header		string			   			true	"Bearer token"
// @Success		200		{object}	PaymentInfoResponse		"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		404		{object}	models.ErrorResponse
// @Failure		409		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/payment/info [get]
func (ctr PaymentController) Info(ctx echo.Context) error {
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

	if user.IsAdmin {
		return ctx.JSON(http.StatusOK, PaymentInfoResponse{Status: models.Paid})
	}

	activePayment, err := ctr.storage.Payments.Get(parsedUserId)
	if err != nil || activePayment == nil {
		ctr.logger.Info("Not found payment")
		return ctx.JSON(http.StatusOK, PaymentInfoResponse{Status: models.NotFound})
	}

	if (activePayment.Status == models.InProgress || activePayment.Status == models.CreatedLink) && int(time.Since(activePayment.UpdatedAt).Minutes()) >= 10 {
		ctr.logger.Info("Expired link")
		return ctx.JSON(http.StatusOK, PaymentInfoResponse{Status: models.NotFound})
	}

	return ctx.JSON(http.StatusOK, PaymentInfoResponse{Status: activePayment.Status})
}
