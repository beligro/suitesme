package payment

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sort"
	"strings"
	"testing"

	"suitesme/internal/utils/security"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Реальные тела callback'ов от Prodamus (успешные и тот, что падал с "некорректная подпись" из-за "/" в payment_type).
const (
	// Успешный: СБП, rub
	prodamusBodySuccess1 = "date=2026-03-07T22%3A12%3A27%2B03%3A00&order_id=42347170&order_num=a9e30986-16f2-4fa0-8cad-62d1192e4035&domain=mneidet.payform.ru&sum=5990.00&currency=rub&customer_phone=%2B79186653575&customer_email=zav-natali%40yandex.ru&customer_extra=&payment_type=%D0%A1%D0%B0%D0%9F&commission=3.8&commission_sum=227.62&attempt=1&sys=mneidet&payments_limit=1&products%5B0%5D%5Bname%5D=%D0%9E%D0%BF%D1%80%D0%B5%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5+%D1%82%D0%B8%D0%BF%D0%B0%D0%B6%D0%B0&products%5B0%5D%5Bprice%5D=5990.00&products%5B0%5D%5Bquantity%5D=1&products%5B0%5D%5Bsum%5D=5990.00&payment_status=success&payment_status_description=%D0%A3%D1%81%D0%BF%D0%B5%D1%88%D0%BD%D0%B0%D1%8F+%D0%BE%D0%BF%D0%BB%D0%B0%D1%82%D0%B0&payment_init=manual"

	// Успешный: Карты банков мира, eur
	prodamusBodySuccess2 = "date=2026-03-08T11%3A58%3A41%2B03%3A00&order_id=42361414&order_num=c0296679-8538-406a-8656-cf1c67e68038&domain=mneidet.payform.ru&sum=5990.00&currency=eur&currency_sum=82.99&currency_commission_sum=8.30&customer_phone=%2B4915563241748&customer_email=kle.ma%40gmx.net&customer_extra=&payment_type=%D0%9A%D0%B0%D1%80%D1%82%D1%8B+%D0%B1%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2+%D0%BC%D0%B8%D1%80%D0%B0+%D0%BA%D1%80%D0%BE%D0%BC%D0%B5+%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B8&commission=10&commission_sum=599.00&attempt=1&sys=mneidet&payments_limit=1&products%5B0%5D%5Bname%5D=%D0%9E%D0%BF%D1%80%D0%B5%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5+%D1%82%D0%B8%D0%BF%D0%B0%D0%B6%D0%B0&products%5B0%5D%5Bprice%5D=5990.00&products%5B0%5D%5Bquantity%5D=1&products%5B0%5D%5Bsum%5D=5990.00&payment_status=success&payment_status_description=%D0%A3%D1%81%D0%BF%D0%B5%D1%88%D0%BD%D0%B0%D1%8F+%D0%BE%D0%BF%D0%BB%D0%B0%D1%82%D0%B0&payment_init=manual"

	// Раньше падал с "некорректная подпись": payment_type=Visa/Mastercard, EUR (слеш в значении)
	prodamusBodyWithSlash = "date=2026-03-07T22%3A59%3A05%2B03%3A00&order_id=42295222&order_num=3d5e6e0b-8f35-481d-8509-76d138215aeb&domain=mneidet.payform.ru&sum=5990.00&currency=eur&currency_sum=79.17&currency_commission_sum=7.92&customer_phone=%2B447425921182&customer_email=victoriialis2%40gmail.com&customer_extra=&payment_type=Visa%2FMastercard%2C+EUR&commission=10&commission_sum=599.00&attempt=22&sys=mneidet&payments_limit=1&products%5B0%5D%5Bname%5D=%D0%9E%D0%BF%D1%80%D0%B5%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5+%D1%82%D0%B8%D0%BF%D0%B0%D0%B6%D0%B0&products%5B0%5D%5Bprice%5D=5990.00&products%5B0%5D%5Bquantity%5D=1&products%5B0%5D%5Bsum%5D=5990.00&payment_status=success&payment_status_description=%D0%A3%D1%81%D0%BF%D0%B5%D1%88%D0%BD%D0%B0%D1%8F+%D0%BE%D0%BF%D0%BB%D0%B0%D1%82%D0%B0&payment_init=manual"

	// Раньше падал: customer_extra содержит HTML-сущность &#128525; (эмодзи) — Go json.Marshal экранировал & в \u0026, Prodamus нет
	prodamusBodyWithAmpersand = "date=2026-03-09T11%3A24%3A02%2B03%3A00&order_id=42396837&order_num=b598df51-fc1a-4602-b472-6eaee020d080&domain=mneidet.payform.ru&sum=5990.00&currency=rub&customer_phone=%2B79500717777&customer_email=surepova%40gmail.com&customer_extra=%D0%9F%D0%BE%D0%B6%D0%B5%D0%BB%D0%B0%D0%BD%D0%B8%D0%B5+%D0%BE%D0%B4%D0%BD%D0%BE+%3A+%D0%BD%D0%B0%D0%BA%D0%BE%D0%BD%D0%B5%D1%86-%D1%82%D0%BE+%D1%83%D0%B7%D0%BD%D0%B0%D1%82%D1%8C+%D1%81%D0%B2%D0%BE%D0%B9+%D1%82%D0%B8%D0%BF%D0%B0%D0%B6+%2C+%D1%81%D0%BA%D0%B2%D0%BE%D0%B7%D1%8C+%D0%B3%D0%BE%D0%B4%D1%8B+%D1%80%D0%B0%D0%B7%D0%BD%D1%8B%D1%85+%D0%BF%D1%80%D0%B5%D0%B4%D0%BF%D0%BE%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B9+%D0%B8+%D0%B4%D0%BE%D0%B3%D0%B0%D0%B4%D0%BE%D0%BA+%26%23128525%3B&payment_type=%D0%A1%D0%91%D0%9F&commission=3.8&commission_sum=227.62&attempt=8&sys=mneidet&payments_limit=1&products%5B0%5D%5Bname%5D=%D0%9E%D0%BF%D1%80%D0%B5%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5+%D1%82%D0%B8%D0%BF%D0%B0%D0%B6%D0%B0&products%5B0%5D%5Bprice%5D=5990.00&products%5B0%5D%5Bquantity%5D=1&products%5B0%5D%5Bsum%5D=5990.00&payment_status=success&payment_status_description=%D0%A3%D1%81%D0%BF%D0%B5%D1%88%D0%BD%D0%B0%D1%8F+%D0%BE%D0%BF%D0%BB%D0%B0%D1%82%D0%B0&payment_init=manual"
)

func parseProdamusBody(t *testing.T, body string) map[string]interface{} {
	t.Helper()
	req := httptest.NewRequest(http.MethodPost, "/api/v1/payment/callback", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	err := req.ParseForm()
	require.NoError(t, err)
	return buildProdamusDataFromForm(req.PostForm)
}

func TestProdamusCallback_SignVerify_RealBodies(t *testing.T) {
	secret := "test_prodamus_secret"
	h := &security.Hmac{}

	for name, body := range map[string]string{
		"success_CBP_rub":       prodamusBodySuccess1,
		"success_cards_eur":     prodamusBodySuccess2,
		"with_slash_visa_eur":   prodamusBodyWithSlash,
		"with_ampersand_extra":  prodamusBodyWithAmpersand,
	} {
		t.Run(name, func(t *testing.T) {
			data := parseProdamusBody(t, body)
			require.NotEmpty(t, data, "parsed data should not be empty")
			require.Equal(t, "success", data["payment_status"])
			sign, err := h.Create(data, secret, "sha256")
			require.NoError(t, err)
			require.NotEmpty(t, sign)
			ok, err := h.Verify(data, secret, sign, "sha256")
			require.NoError(t, err)
			assert.True(t, ok, "Verify(create(data)) must pass for real Prodamus body")
		})
	}
}

func TestProdamusCallback_ParseBodyWithSlash(t *testing.T) {
	data := parseProdamusBody(t, prodamusBodyWithSlash)
	assert.Equal(t, "Visa/Mastercard, EUR", data["payment_type"],
		"payment_type должен декодироваться с слешем (Visa/Mastercard, EUR)")
	assert.Equal(t, "42295222", data["order_id"])
	assert.Equal(t, "3d5e6e0b-8f35-481d-8509-76d138215aeb", data["order_num"])
}

func TestProdamusCallback_ParseBodyWithAmpersand(t *testing.T) {
	data := parseProdamusBody(t, prodamusBodyWithAmpersand)
	extra, _ := data["customer_extra"].(string)
	assert.Contains(t, extra, "&#128525;", "customer_extra должен содержать HTML-сущность как в теле запроса")
	assert.Equal(t, "42396837", data["order_id"])
	assert.Equal(t, "b598df51-fc1a-4602-b472-6eaee020d080", data["order_num"])
}

// prodamusStyleSign считает подпись как Prodamus: сортировка по ключам, без HTML-экранирования, экранирование / в JSON.
func prodamusStyleSign(data interface{}, secret string) string {
	dataMap, _ := toMapForSign(data)
	sortMapForSign(dataMap)
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(false)
	_ = enc.Encode(dataMap)
	dataJSON := bytes.TrimSpace(buf.Bytes())
	dataJSON = bytes.ReplaceAll(dataJSON, []byte("/"), []byte("\\/"))
	h := hmac.New(sha256.New, []byte(secret))
	h.Write(dataJSON)
	return fmt.Sprintf("%x", h.Sum(nil))
}

func toMapForSign(data interface{}) (map[string]interface{}, error) {
	raw, _ := json.Marshal(data)
	var out map[string]interface{}
	err := json.Unmarshal(raw, &out)
	return out, err
}

func sortMapForSign(m map[string]interface{}) {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	sorted := make(map[string]interface{}, len(m))
	for _, k := range keys {
		v := m[k]
		if arr, ok := v.([]interface{}); ok {
			for i, item := range arr {
				if nm, ok := item.(map[string]interface{}); ok {
					sortMapForSign(nm)
					arr[i] = nm
				}
			}
		}
		sorted[k] = v
	}
	for k, v := range sorted {
		m[k] = v
	}
}

// TestProdamusCallback_VerifyAcceptsProdamusStyleSign проверяет, что Verify принимает подпись,
// посчитанную с экранированием / (как у Prodamus). Без доработки в hmac.go этот тест падает.
func TestProdamusCallback_VerifyAcceptsProdamusStyleSign(t *testing.T) {
	secret := "test_prodamus_secret"
	data := parseProdamusBody(t, prodamusBodyWithSlash)
	signFromProdamus := prodamusStyleSign(data, secret) // как считает Prodamus (с экранированием /)
	h := &security.Hmac{}
	ok, err := h.Verify(data, secret, signFromProdamus, "sha256")
	require.NoError(t, err)
	assert.True(t, ok, "Verify должен принимать подпись Prodamus (с экранированием / в JSON); без доработки в hmac.go тест падает")
}
