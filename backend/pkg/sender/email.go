package sender

import (
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"net"
	"net/smtp"
	"strings"
	"suitesme/internal/config"
	"time"
	"unicode/utf8"
)

// EmailMessage represents an email message with all necessary fields
type EmailMessage struct {
	From        string
	To          string
	Subject     string
	PlainText   string
	HTMLContent string
}

// encodeRFC2047 encodes non-ASCII strings for email headers (RFC 2047)
func encodeRFC2047(s string) string {
	if s == "" {
		return s
	}
	needsEnc := false
	for _, r := range s {
		if r > 127 {
			needsEnc = true
			break
		}
	}
	if !needsEnc || !utf8.ValidString(s) {
		return s
	}
	return "=?UTF-8?B?" + base64.StdEncoding.EncodeToString([]byte(s)) + "?="
}

// SendFormattedEmail sends a properly formatted email with headers to avoid spam filters
func SendFormattedEmail(emailTo string, msg EmailMessage, cfg *config.Config) error {
	// Set up headers
	headers := make(map[string]string)
	headers["From"] = msg.From
	headers["To"] = msg.To
	headers["Subject"] = encodeRFC2047(msg.Subject)
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

	// SSL/TLS config: implicit TLS (SMTPS, port 465) or STARTTLS (port 587)
	tlsConfig := &tls.Config{
		ServerName:         cfg.SmtpHost,
		MinVersion:         tls.VersionTLS12,
		InsecureSkipVerify: true, // для SMTP с самоподписанными сертификатами
	}

	// Try implicit TLS/SSL first (port 465)
	conn, err := tls.Dial("tcp", cfg.SmtpHost+":"+cfg.SmtpPort, tlsConfig)
	if err != nil {
		// Fallback to STARTTLS (port 587)
		return sendWithSTARTTLS(emailTo, messageBody.String(), cfg, tlsConfig)
	}

	client, err := smtp.NewClient(conn, cfg.SmtpHost)
	if err != nil {
		conn.Close()
		return sendWithSTARTTLS(emailTo, messageBody.String(), cfg, tlsConfig)
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

// sendWithSTARTTLS connects via plain TCP and upgrades to TLS with STARTTLS (port 587)
func sendWithSTARTTLS(emailTo string, messageBody string, cfg *config.Config, tlsConfig *tls.Config) error {
	conn, err := net.Dial("tcp", cfg.SmtpHost+":"+cfg.SmtpPort)
	if err != nil {
		return err
	}
	defer conn.Close()

	client, err := smtp.NewClient(conn, cfg.SmtpHost)
	if err != nil {
		return err
	}
	defer client.Close()

	if err = client.StartTLS(tlsConfig); err != nil {
		return err
	}

	auth := smtp.PlainAuth("", cfg.EmailSendFrom, cfg.EmailPassword, cfg.SmtpHost)
	if err = client.Auth(auth); err != nil {
		return err
	}
	if err = client.Mail(cfg.EmailSendFrom); err != nil {
		return err
	}
	if err = client.Rcpt(emailTo); err != nil {
		return err
	}

	writer, err := client.Data()
	if err != nil {
		return err
	}
	_, err = writer.Write([]byte(messageBody))
	if err != nil {
		return err
	}
	if err = writer.Close(); err != nil {
		return err
	}

	return client.Quit()
}
