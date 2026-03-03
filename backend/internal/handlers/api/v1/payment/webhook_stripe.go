package payment

import (
	"encoding/json"
	"io"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/stripe/stripe-go/v84"
	"github.com/stripe/stripe-go/v84/webhook"

	"suitesme/internal/models"
	"suitesme/internal/utils/external"
)

type stripeSessionObject struct {
	ID       string            `json:"id"`
	Metadata map[string]string `json:"metadata"`
}

// StripeWebhook handles Stripe webhook events (checkout.session.completed, checkout.session.expired).
// Events are ignored unless session metadata["source"] matches config.StripeWebhookSource (e.g. "ai_mne_idet").
// Raw body is required for signature verification; do not use body middleware that consumes it before this handler.
func (ctr PaymentController) StripeWebhook(ctx echo.Context) error {

	if ctr.config.StripeWebhookSecret == "" {
		ctr.logger.Error("Stripe webhook secret is not set")
		return ctx.JSON(http.StatusInternalServerError, nil)
	}

	body, err := io.ReadAll(ctx.Request().Body)
	if err != nil {
		ctr.logger.Error(err)
		return ctx.JSON(http.StatusBadRequest, nil)
	}
	signature := ctx.Request().Header.Get("Stripe-Signature")

	event, err := webhook.ConstructEvent(body, signature, ctr.config.StripeWebhookSecret)
	if err != nil {
		ctr.logger.Warn("Stripe webhook signature verification failed: ", err)
		return ctx.JSON(http.StatusBadRequest, nil)
	}

	switch event.Type {
	case stripe.EventTypeCheckoutSessionCompleted:
		return ctr.handleCheckoutSessionCompleted(ctx, event)
	case stripe.EventTypeCheckoutSessionExpired:
		return ctr.handleCheckoutSessionExpired(ctx, event)
	default:
		return ctx.JSON(http.StatusOK, models.EmptyResponse{})
	}
}

// isOurSession returns true if the session metadata source matches our config (same webhook used for multiple sites).
func (ctr PaymentController) isOurSession(sessionObj *stripeSessionObject) bool {
	if ctr.config.StripeWebhookSource == "" {
		return true
	}
	source, ok := sessionObj.Metadata["source"]
	return ok && source == ctr.config.StripeWebhookSource
}

func (ctr PaymentController) parseSessionFromEvent(event stripe.Event) (*stripeSessionObject, error) {
	var sessionObj stripeSessionObject
	if err := json.Unmarshal(event.Data.Raw, &sessionObj); err != nil {
		return nil, err
	}
	return &sessionObj, nil
}

func (ctr PaymentController) handleCheckoutSessionCompleted(ctx echo.Context, event stripe.Event) error {
	sessionObj, err := ctr.parseSessionFromEvent(event)
	if err != nil {
		ctr.logger.Error("Failed to unmarshal checkout session: ", err)
		return ctx.JSON(http.StatusInternalServerError, nil)
	}
	if sessionObj.ID == "" {
		ctr.logger.Warn("Stripe session id is empty")
		return ctx.JSON(http.StatusOK, models.EmptyResponse{})
	}
	if !ctr.isOurSession(sessionObj) {
		return ctx.JSON(http.StatusOK, models.EmptyResponse{})
	}

	payment, err := ctr.storage.Payments.GetByStripeSessionID(sessionObj.ID)
	if err != nil || payment == nil {
		ctr.logger.Warn("Payment not found for Stripe session: ", sessionObj.ID)
		return ctx.JSON(http.StatusOK, models.EmptyResponse{})
	}

	payment.Status = models.Paid
	ctr.storage.Payments.Save(payment)
	ctr.logger.Info("Payment marked as paid for Stripe session: ", sessionObj.ID)

	user, err := ctr.storage.User.Get(payment.UserId)
	if err == nil && user != nil && user.AmocrmLeadId != 0 {
		if err := external.UpdateLeadStatus(ctr.config, ctr.logger, user.AmocrmLeadId, external.Paid, nil); err != nil {
			ctr.logger.Error("Failed to update AmoCRM lead: ", err)
		}
	}

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}

func (ctr PaymentController) handleCheckoutSessionExpired(ctx echo.Context, event stripe.Event) error {
	sessionObj, err := ctr.parseSessionFromEvent(event)
	if err != nil {
		ctr.logger.Error("Failed to unmarshal checkout session: ", err)
		return ctx.JSON(http.StatusInternalServerError, nil)
	}
	if sessionObj.ID == "" {
		return ctx.JSON(http.StatusOK, models.EmptyResponse{})
	}
	if !ctr.isOurSession(sessionObj) {
		return ctx.JSON(http.StatusOK, models.EmptyResponse{})
	}

	payment, err := ctr.storage.Payments.GetByStripeSessionID(sessionObj.ID)
	if err != nil || payment == nil {
		return ctx.JSON(http.StatusOK, models.EmptyResponse{})
	}

	payment.Status = models.Failed
	ctr.storage.Payments.Save(payment)
	ctr.logger.Info("Payment marked as failed (expired) for Stripe session: ", sessionObj.ID)

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
