package sender

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"suitesme/internal/config"
	"time"

	"github.com/google/uuid"
)

const rusenderSendURL = "https://api.rusender.ru/api/v1/external-mails/send"

// EmailMessage represents an email message with all necessary fields
type EmailMessage struct {
	From        string
	To          string
	Subject     string
	PlainText   string
	HTMLContent string
}

// rusenderRequest — тело запроса к RuSender API (см. https://rusender.ru/developer/api/email/)
type rusenderRequest struct {
	IdempotencyKey string       `json:"idempotencyKey"`
	Mail           rusenderMail `json:"mail"`
}

type rusenderMail struct {
	To      rusenderAddr `json:"to"`
	From    rusenderAddr `json:"from"`
	Subject string       `json:"subject"`
	HTML    string       `json:"html,omitempty"`
	Text    string       `json:"text,omitempty"`
}

type rusenderAddr struct {
	Email string `json:"email"`
	Name  string `json:"name,omitempty"`
}

// SendFormattedEmail sends email via RuSender API.
// Требуется RUSENDER_API_KEY и EMAIL_SEND_FROM в конфиге.
func SendFormattedEmail(emailTo string, msg EmailMessage, cfg *config.Config) error {
	if cfg.RuSenderApiKey == "" {
		return fmt.Errorf("RUSENDER_API_KEY is not set")
	}
	if cfg.EmailSendFrom == "" {
		return fmt.Errorf("EMAIL_SEND_FROM is not set")
	}

	text := msg.PlainText
	html := msg.HTMLContent
	if text == "" && html == "" {
		return fmt.Errorf("email must have at least plain text or HTML content")
	}
	if text == "" {
		text = html
	}
	if html == "" {
		html = text
	}

	body := rusenderRequest{
		IdempotencyKey: uuid.New().String(),
		Mail: rusenderMail{
			To: rusenderAddr{
				Email: emailTo,
			},
			From: rusenderAddr{
				Email: cfg.EmailSendFrom,
			},
			Subject: msg.Subject,
			HTML:    html,
			Text:    text,
		},
	}

	raw, err := json.Marshal(body)
	if err != nil {
		return fmt.Errorf("rusender request marshal: %w", err)
	}

	req, err := http.NewRequest(http.MethodPost, rusenderSendURL, bytes.NewReader(raw))
	if err != nil {
		return fmt.Errorf("rusender request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Api-Key", cfg.RuSenderApiKey)

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("rusender send: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		return nil
	}

	var errBody struct {
		Message    string `json:"message"`
		StatusCode int    `json:"statusCode"`
	}
	_ = json.NewDecoder(resp.Body).Decode(&errBody)
	if errBody.Message != "" {
		return fmt.Errorf("rusender API %d: %s", resp.StatusCode, errBody.Message)
	}
	return fmt.Errorf("rusender API error: HTTP %d", resp.StatusCode)
}
