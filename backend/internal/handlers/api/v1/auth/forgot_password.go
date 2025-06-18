package auth

import (
	"errors"
	"net/http"
	"suitesme/internal/models"
	"suitesme/internal/utils/security"
	"suitesme/pkg/myerrors"
	"suitesme/pkg/sender"
	"time"

	utils_request "suitesme/internal/utils/request"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type ForgotPasswordRequest struct {
	Email string `json:"email" validate:"required"`
}

// @Summary		Forgot password
// @Description	User forgot password
// @ID			auth-forgot-password
// @Accept		json
// @Produce		json
// @Tags		auth
// @Param		request	body		ForgotPasswordRequest			true	"Request"
// @Success		200		{object}	models.EmptyResponse					"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		401		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/auth/forgot_password [post]
func (ctr AuthController) ForgotPassword(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	request, err := utils_request.ParseRequest[ForgotPasswordRequest](&ctx)
	if err != nil {
		return err
	}

	user, err := ctr.storage.User.GetByEmail(request.Email)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		ctr.logger.Warn("User not found")
		return myerrors.GetHttpErrorByCode(myerrors.UserNotFound, ctx)
	}
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	if !user.IsVerified {
		return myerrors.GetHttpErrorByCode(myerrors.UserNotExists, ctx)
	}

	resetToken := security.GetResetToken()

	user.PasswordResetToken = resetToken
	user.PasswordResetAt = time.Now().Add(time.Minute * 15)

	urlToken, err := security.Encode(&security.ResetTokenStruct{UserId: user.ID, ResetToken: resetToken})
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.SendingEmailFailed, ctx)
	}

	ctr.storage.User.Save(user)

	// Create a better formatted email with HTML content
	resetLink := "http://51.250.84.195:3000/password_reset?token=" + urlToken
	plainText := "You requested a password reset for your SuitesMe account.\n\n" +
		"Please use the following link to reset your password: " + resetLink + "\n\n" +
		"If you didn't request a password reset, please ignore this email."

	htmlContent := "<html><body>" +
		"<h2>SuitesMe Password Reset</h2>" +
		"<p>You requested a password reset for your SuitesMe account.</p>" +
		"<p>Please click the button below to reset your password:</p>" +
		"<div style='text-align: center; margin: 30px 0;'>" +
		"<a href='" + resetLink + "' style='background-color: #4CAF50; color: white; padding: 12px 20px; " +
		"text-decoration: none; border-radius: 4px; font-weight: bold;'>Reset Password</a>" +
		"</div>" +
		"<p>Or copy and paste this link into your browser:</p>" +
		"<p style='background-color: #f5f5f5; padding: 10px; word-break: break-all;'>" + resetLink + "</p>" +
		"<p>If you didn't request a password reset, please ignore this email.</p>" +
		"<p>This link will expire in 15 minutes.</p>" +
		"</body></html>"

	// Create email message
	emailMsg := sender.EmailMessage{
		From:        ctr.config.EmailSendFrom,
		To:          request.Email,
		Subject:     "SuitesMe Password Reset Request",
		PlainText:   plainText,
		HTMLContent: htmlContent,
	}

	// Send the email
	err = sender.SendFormattedEmail(request.Email, emailMsg, ctr.config)
	if err != nil {
		ctr.logger.Error(err.Error())
		return myerrors.GetHttpErrorByCode(myerrors.SendingEmailFailed, ctx)
	}

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
