package sender

import (
	"net/smtp"
	"suitesme/internal/config"
)

func SendEmail(emailTo string, verificationCode string, cfg *config.Config) error {
	msg := []byte("Verification code is: " + verificationCode)
	auth := smtp.PlainAuth("", cfg.EmailSendFrom, cfg.EmailPassword, cfg.SmtpHost)
	err := smtp.SendMail(cfg.SmtpHost+":"+cfg.SmtpPort, auth, cfg.EmailSendFrom, []string{emailTo}, msg)
	if err != nil {
		return err
	}
	return nil
}
