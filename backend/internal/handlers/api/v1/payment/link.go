package payment

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"suitesme/internal/models"
	"suitesme/internal/utils/external"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
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
		return myerrors.GetHttpErrorByCode(http.StatusUnauthorized)
	}

	parsedUserId := userID.(uuid.UUID)

	user, err := ctr.storage.User.Get(parsedUserId)

	if err != nil {
		ctr.logger.Error(err)
		return myerrors.ParseGormErrorToHttp(err)
	}

	if user == nil {
		return myerrors.GetHttpErrorByCode(http.StatusNotFound)
	}

	link, err := external.CreatePaymentLink(ctr.config, user)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	activePayment := ctr.storage.Payments.Get(parsedUserId)
	if activePayment != nil {
		if activePayment.Status == models.Paid {
			ctr.logger.Info("Already paid")
			return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
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
		PaymentSum:  "100", // TODO: get sum from common place
	}

	err = ctr.storage.Payments.Create(&payment)

	if err != nil {
		ctr.logger.Error(err)
		return myerrors.ParseGormErrorToHttp(err)
	}

	return ctx.JSON(http.StatusOK, PaymentLinkResponse{Link: link})
}
