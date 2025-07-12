package sender

import (
	"crypto/tls"
	"fmt"
	"net/smtp"
	"strings"
	"suitesme/internal/config"
	"time"
)

// EmailMessage represents an email message with all necessary fields
type EmailMessage struct {
	From        string
	To          string
	Subject     string
	PlainText   string
	HTMLContent string
}

// SendFormattedEmail sends a properly formatted email with headers to avoid spam filters
func SendFormattedEmail(emailTo string, msg EmailMessage, cfg *config.Config) error {
	// Set up headers
	headers := make(map[string]string)
	headers["From"] = msg.From
	headers["To"] = msg.To
	headers["Subject"] = msg.Subject
	headers["MIME-Version"] = "1.0"
	headers["Date"] = time.Now().Format(time.RFC1123Z)
	headers["Message-ID"] = fmt.Sprintf("<%d.%s>", time.Now().Unix(), msg.From)

	// Generate a boundary for multipart messages
	boundary := "SuitesMeEmailBoundary"

	// Set Content-Type header for multipart messages
	headers["Content-Type"] = "multipart/alternative; boundary=" + boundary

	// Build the message
	var messageBody strings.Builder

	// Add headers
	for key, value := range headers {
		messageBody.WriteString(fmt.Sprintf("%s: %s\r\n", key, value))
	}
	messageBody.WriteString("\r\n")

	// Add plain text part
	messageBody.WriteString(fmt.Sprintf("--%s\r\n", boundary))
	messageBody.WriteString("Content-Type: text/plain; charset=UTF-8\r\n")
	messageBody.WriteString("Content-Transfer-Encoding: quoted-printable\r\n\r\n")
	messageBody.WriteString(msg.PlainText)
	messageBody.WriteString("\r\n\r\n")

	// Add HTML part if provided
	if msg.HTMLContent != "" {
		messageBody.WriteString(fmt.Sprintf("--%s\r\n", boundary))
		messageBody.WriteString("Content-Type: text/html; charset=UTF-8\r\n")
		messageBody.WriteString("Content-Transfer-Encoding: quoted-printable\r\n\r\n")
		messageBody.WriteString(msg.HTMLContent)
		messageBody.WriteString("\r\n\r\n")
	}

	// Close the boundary
	messageBody.WriteString(fmt.Sprintf("--%s--", boundary))

	// Connect to the SMTP server with TLS
	tlsConfig := &tls.Config{
		InsecureSkipVerify: true,
		ServerName:         cfg.SmtpHost,
	}

	// Connect to the server
	conn, err := tls.Dial("tcp", cfg.SmtpHost+":"+cfg.SmtpPort, tlsConfig)
	if err != nil {
		// Fallback to non-TLS if TLS connection fails
		return sendWithoutTLS(emailTo, messageBody.String(), cfg)
	}

	client, err := smtp.NewClient(conn, cfg.SmtpHost)
	if err != nil {
		return sendWithoutTLS(emailTo, messageBody.String(), cfg)
	}

	// Authenticate
	auth := smtp.PlainAuth("", cfg.EmailSendFrom, cfg.EmailPassword, cfg.SmtpHost)
	if err = client.Auth(auth); err != nil {
		return err
	}

	// Set the sender and recipient
	if err = client.Mail(cfg.EmailSendFrom); err != nil {
		return err
	}
	if err = client.Rcpt(emailTo); err != nil {
		return err
	}

	// Send the email body
	writer, err := client.Data()
	if err != nil {
		return err
	}

	_, err = writer.Write([]byte(messageBody.String()))
	if err != nil {
		return err
	}

	err = writer.Close()
	if err != nil {
		return err
	}

	return client.Quit()
}

// sendWithoutTLS is a fallback method when TLS connection fails
func sendWithoutTLS(emailTo string, messageBody string, cfg *config.Config) error {
	auth := smtp.PlainAuth("", cfg.EmailSendFrom, cfg.EmailPassword, cfg.SmtpHost)
	return smtp.SendMail(
		cfg.SmtpHost+":"+cfg.SmtpPort,
		auth,
		cfg.EmailSendFrom,
		[]string{emailTo},
		[]byte(messageBody),
	)
}
