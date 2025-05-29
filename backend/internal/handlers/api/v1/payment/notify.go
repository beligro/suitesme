package payment

import (
	"errors"
	"net/http"
	"suitesme/pkg/myerrors"

	"suitesme/internal/models"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

// @Summary		payment notify status=OK
// @Description	payment-notify
// @ID			payment-notify
// @Accept		json
// @Produce		json
// @Tags		payment
// @Param		Authorization	header		string			   			true	"Bearer token"
// @Success		200		{object}	models.EmptyResponse		"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		404		{object}	models.ErrorResponse
// @Failure		409		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/payment/notify [post]
func (ctr PaymentController) PaymentNotify(ctx echo.Context) error {
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

	activePayment, err := ctr.storage.Payments.Get(parsedUserId)
	if err != nil || activePayment == nil {
		return myerrors.GetHttpErrorByCode(myerrors.PaymentNotFound, ctx)
	}
	if activePayment.Status == models.CreatedLink {
		activePayment.Status = models.InProgress
	}
	ctr.storage.Payments.Save(activePayment)

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
