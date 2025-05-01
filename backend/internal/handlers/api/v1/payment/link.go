package payment

import (
	"errors"
	"net/http"
	"strings"
	"suitesme/pkg/myerrors"

	"suitesme/internal/caches"
	"suitesme/internal/models"
	"suitesme/internal/utils/external"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type PaymentLinkResponse struct {
	Link string `json:"link" validate:"required"`
}

// @Summary		Get payment link
// @Description	Get payment-link
// @ID			get-payment-link
// @Accept		json
// @Produce		json
// @Tags		payment
// @Param		Authorization	header		string			   			true	"Bearer token"
// @Success		200		{object}	PaymentLinkResponse		"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		404		{object}	models.ErrorResponse
// @Failure		409		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/payment/link [post]
func (ctr PaymentController) PaymentLink(ctx echo.Context) error {
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

	settingsCache := caches.GetSettingsCache(ctr.storage, ctr.settingsCache)

	link, err := external.CreatePaymentLink(user, settingsCache)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.ExternalError, ctx)
	}
	if !strings.HasPrefix(link, "http") {
		ctr.logger.Warn("Error while retrieving link: ", link)
		return ctx.JSON(http.StatusBadRequest, myerrors.MyError{Code: "bad_request", Message: link})
	}

	activePayment, err := ctr.storage.Payments.Get(parsedUserId)
	if err == nil && activePayment != nil {
		if activePayment.Status == models.Paid {
			ctr.logger.Info("Already paid")
			return myerrors.GetHttpErrorByCode(myerrors.AlreadyPaid, ctx)
		}
		activePayment.Status = models.CreatedLink
		activePayment.PaymentLink = link
		ctr.storage.Payments.Save(activePayment)
		return ctx.JSON(http.StatusOK, PaymentLinkResponse{Link: link})
	}

	payment := models.DbPayments{
		UserId:      parsedUserId,
		Status:      models.CreatedLink,
		PaymentLink: link,
		PaymentSum:  settingsCache["price"],
	}

	ctr.storage.Payments.Create(&payment)

	return ctx.JSON(http.StatusOK, PaymentLinkResponse{Link: link})
}
