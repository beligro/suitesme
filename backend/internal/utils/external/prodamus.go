package external

import (
	"io"
	"net/http"
	"suitesme/internal/models"
)

const (
	defaultProdamusBaseURL = "https://mneidet.payform.ru"
)

var (
	prodamusClient  = &http.Client{}
	prodamusBaseURL = defaultProdamusBaseURL
)

func CreatePaymentLink(user *models.DbUser, settings map[string]string) (string, error) {
	req, err := http.NewRequest("GET", prodamusBaseURL+"/", nil)
	if err != nil {
		return "", err
	}

	query := req.URL.Query()
	query.Add("order_id", user.ID.String())
	query.Add("do", "link")
	query.Add("sys", "mneidet")
	query.Add("products[0][name]", settings["payment_name"])
	query.Add("products[0][price]", settings["price"])
	query.Add("products[0][quantity]", "1")
	query.Add("paid_content", "Определение типажа")
	query.Add("customer_email", user.Email)
	query.Add("urlReturn", settings["frontend_domain"]+"/profile/payment?status=fail")
	query.Add("urlSuccess", settings["frontend_domain"]+"/profile/payment?status=ok")
	query.Add("urlNotification", settings["backend_domain"]+"/api/v1/payment/callback")
	query.Add("currency", "rub")
	query.Add("payments_limit", "1")
	// TODO: remove it
	query.Add("demo_mode", "1")
	req.URL.RawQuery = query.Encode()

	resp, err := prodamusClient.Do(req)
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
