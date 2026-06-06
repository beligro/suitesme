package external

import (
	"fmt"
	"strconv"

	"github.com/stripe/stripe-go/v84"
	"github.com/stripe/stripe-go/v84/checkout/session"

	"suitesme/internal/models"
)

// CreateStripeCheckoutSession creates a Stripe Checkout Session for one-time payment in EUR.
// settings must contain: euro_price (in euros, e.g. "59" or "59.00"), frontend_domain, payment_name.
// sourceKey is stored in session metadata and used in webhook to filter events (e.g. "ai_mne_idet").
// Returns session ID, session URL, or error.
func CreateStripeCheckoutSession(user *models.DbUser, settings map[string]string, secretKey string, sourceKey string) (sessionID, sessionURL string, err error) {
	euroPriceStr, ok := settings["euro_price"]
	if !ok || euroPriceStr == "" {
		return "", "", fmt.Errorf("euro_price is required for Stripe payment")
	}
	euroPrice, err := strconv.ParseFloat(euroPriceStr, 64)
	if err != nil || euroPrice <= 0 {
		return "", "", fmt.Errorf("invalid euro_price: %s", euroPriceStr)
	}
	amountCents := int64(euroPrice * 100)

	frontendDomain := settings["frontend_domain"]
	if frontendDomain == "" {
		return "", "", fmt.Errorf("frontend_domain is required")
	}
	successURL := frontendDomain + "/payment?status=ok"
	cancelURL := frontendDomain + "/payment?status=fail"

	productName := settings["payment_name"]
	if productName == "" {
		productName = "Personal Image Analysis Service"
	}

	stripe.Key = secretKey

	params := &stripe.CheckoutSessionParams{
		SuccessURL:    stripe.String(successURL),
		CancelURL:     stripe.String(cancelURL),
		Mode:          stripe.String(string(stripe.CheckoutSessionModePayment)),
		CustomerEmail: stripe.String(user.Email),
		LineItems: []*stripe.CheckoutSessionLineItemParams{
			{
				PriceData: &stripe.CheckoutSessionLineItemPriceDataParams{
					Currency:   stripe.String("eur"),
					UnitAmount: stripe.Int64(amountCents),
					ProductData: &stripe.CheckoutSessionLineItemPriceDataProductDataParams{
						Name: stripe.String(productName),
					},
				},
				Quantity: stripe.Int64(1),
			},
		},
	}
	params.AddMetadata("user_id", user.ID.String())
	if sourceKey != "" {
		params.AddMetadata("source", sourceKey)
	}

	sess, err := session.New(params)
	if err != nil {
		return "", "", err
	}
	if sess.ID == "" {
		return "", "", fmt.Errorf("stripe returned empty session id")
	}
	url := ""
	if sess.URL != "" {
		url = sess.URL
	}
	return sess.ID, url, nil
}
