package payment

import (
	"encoding/json"
	"net/http"
	"net/url"
	"strconv"
	"suitesme/internal/models"
	"suitesme/internal/utils/security"
	"suitesme/pkg/myerrors"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type CallbackRequest struct {
	OrderId                  *string   `json:"order_id"`
	OrderNum                 uuid.UUID `json:"order_num" validate:"required"`
	Domain                   *string   `json:"domain"`
	Sum                      *string   `json:"sum"`
	PaymentStatus            string    `json:"payment_status" validate:"required"`
	PaymentStatusDescription *string   `json:"payment_status_description"`
}

func isProductField(key string) bool {
	return len(key) > 9 && key[:9] == "products["
}

// Parses a product field, extracting the index and the actual key for the product
func parseProductField(key string) (index int, productKey string) {
	indexStart := 9 // position after "products["
	indexEnd := indexStart
	for ; indexEnd < len(key) && key[indexEnd] != ']'; indexEnd++ {
	}
	index, _ = strconv.Atoi(key[indexStart:indexEnd])

	keyStart := indexEnd + 2 // skip over "]["
	keyEnd := keyStart
	for ; keyEnd < len(key) && key[keyEnd] != ']'; keyEnd++ {
	}
	productKey = key[keyStart:keyEnd]

	return index, productKey
}

// @Summary		Get payment callback
// @Description	Get payment-callback
// @ID			get-payment-callback
// @Accept		json
// @Produce		json
// @Tags		payment
// @Param		Authorization	header		string			true	"Bearer token"
// @Success		200		{object}	models.EmptyResponse			"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		404		{object}	models.ErrorResponse
// @Failure		409		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/payment/callback [post]
func (ctr PaymentController) PaymentCallback(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	data := make(map[string]interface{})
	products := make([]interface{}, 0)

	for key, values := range ctx.Request().PostForm {
		decodedKey, _ := url.QueryUnescape(key)
		if len(values) > 0 {
			if isProductField(decodedKey) {
				// Handle product fields
				productIndex, productKey := parseProductField(decodedKey)
				for len(products) <= productIndex {
					products = append(products, map[string]interface{}{})
				}
				productMap := products[productIndex].(map[string]interface{})
				productMap[productKey] = values[0]
			} else {
				// Add regular fields to data
				data[decodedKey] = values[0]
			}
		}
	}

	if len(products) > 0 {
		data["products"] = products
	}

	sign := ctx.Request().Header.Get("Sign")
	ctr.logger.Infoln("header sign is: ", sign)
	h := security.Hmac{}
	isEqual, err := h.Verify(data, ctr.config.ProdamusToken, sign, "sha256", ctr.logger)
	if err != nil {
		ctr.logger.Errorln("Error:", err)
		return myerrors.GetHttpErrorByCode(myerrors.IncorrectSign, ctx)
	}
	if !isEqual {
		ctr.logger.Error("Different signatures")
		return myerrors.GetHttpErrorByCode(myerrors.IncorrectSign, ctx)
	}

	jsonData, _ := json.Marshal(data)

	var request CallbackRequest
	json.Unmarshal(jsonData, &request)

	payment := ctr.storage.Payments.Get(request.OrderNum)
	if payment == nil {
		ctr.logger.Error("Not found payment")
		return myerrors.GetHttpErrorByCode(myerrors.PaymentNotFound, ctx)
	}

	if request.Sum != nil && *request.Sum < payment.PaymentSum {
		ctr.logger.Error("Sum is less than required")
		return myerrors.GetHttpErrorByCode(myerrors.DifferentPaymentSum, ctx)
	}

	payment.ProdamusOrderId = request.OrderId
	if request.PaymentStatus == "success" {
		payment.Status = models.Paid
	} else {
		payment.Status = models.Failed
	}

	ctr.storage.Payments.Save(payment)

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
