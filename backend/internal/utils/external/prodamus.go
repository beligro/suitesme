package external

import (
	"io"
	"net/http"
	"suitesme/internal/config"
	"suitesme/internal/models"
)

func CreatePaymentLink(cfg *config.Config, user *models.DbUser) (string, error) {
	client := &http.Client{}

	req, err := http.NewRequest("GET", "https://mneidet.payform.ru/", nil)
	if err != nil {
		return "", err
	}

	query := req.URL.Query()
	query.Add("order_id", user.ID.String())
	query.Add("do", "link")
	query.Add("products[0][name]", "Определение типажа")
	query.Add("products[0][price]", "100")
	query.Add("products[0][quantity]", "1")
	query.Add("customer_email", user.Email)
	query.Add("urlReturn", "http://51.250.84.195:3000/profile/payment?status=fail")
	query.Add("urlSuccess", "http://51.250.84.195:3000/profile/payment?status=ok")
	query.Add("urlNotification", "http://51.250.84.195:8080/api/v1/payment/callback")
	query.Add("callbackType", "json")
	query.Add("currency", "rub")
	query.Add("payments_limit", "1")
	// TODO: remove it
	query.Add("demo_mode", "1")
	req.URL.RawQuery = query.Encode()

	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}
