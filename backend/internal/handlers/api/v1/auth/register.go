package auth

import (
	"net/http"
	"suitesme/internal/models"
	"suitesme/internal/utils/security"
	"suitesme/pkg/myerrors"
	"suitesme/pkg/sender"

	utils_request "suitesme/internal/utils/request"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type RegisterRequest struct {
	Email           string `json:"email" validate:"required"`
	Password        string `json:"password" validate:"required"`
	PasswordConfirm string `json:"password_confirm" validate:"required"`
	FirstName       string `json:"first_name" validate:"required"`
	LastName        string `json:"last_name" validate:"required"`
	BirthDate       string `json:"birth_date" validate:"required"`
}

type RegisterResponse struct {
	UserId uuid.UUID `json:"user_id" validate:"required"`
}

// @Summary		Register user
// @Description	Register user and send verification email
// @ID			auth-register
// @Accept		json
// @Produce		json
// @Tags		auth
// @Param		request	body		RegisterRequest			true	"Request"
// @Success		200		{object}	RegisterResponse		"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		409		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/auth/register [post]
func (ctr AuthController) Register(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	request, err := utils_request.ParseRequest[RegisterRequest](&ctx)
	if err != nil {
		return err
	}

	if request.Password != request.PasswordConfirm {
		ctr.logger.Warn("Passwords are different")
		return myerrors.GetHttpErrorByCode(myerrors.DifferrentPasswords, ctx)
	}

	userExists := ctr.storage.User.CheckVerifiedUserExists(request.Email)

	if userExists {
		return myerrors.GetHttpErrorByCode(myerrors.UserAlreadyExists, ctx)
	}

	verificationCode := security.GetVerificationCode()
	passwordHash, err := security.HashPassword(request.Password)
	if err != nil {
		ctr.logger.Error(err.Error())
		return myerrors.GetHttpErrorByCode(myerrors.IncorrectPassword, ctx)
	}

	newUser := &models.DbUser{
		Email:            request.Email,
		PasswordHash:     string(passwordHash),
		FirstName:        request.FirstName,
		LastName:         request.LastName,
		BirthDate:        request.BirthDate,
		VerificationCode: verificationCode,
		IsVerified:       false,
	}

	userId := ctr.storage.User.Create(newUser)

	// Create a better formatted email with HTML content
	plainText := "Ваш код подтверждения: " + verificationCode
	htmlContent := "<html><body>" +
		"<h2>Здравствуйте, " + request.FirstName + "!</h2>" +
		"<p>Поздравляем вас с успешной регистрацией</p>" +
		"<p>Ваш код подтверждения:</p>" +
		"<div style='background-color: #f5f5f5; padding: 10px; margin: 20px 0; font-size: 18px; font-weight: bold; text-align: center;'>" +
		verificationCode +
		"</div>" +
		"<p>Войдите в свой личный кабинет по адресу: " + request.Email + "</p>" +
		"<p>И узнайте свой типаж!</p>" +
		"<p></p>" +
		"<p></p>" +
		"<p>С уважением,</p>" +
		"<p>команда MNE IDET</p>" +
		"</body></html>"

	// Create email message
	emailMsg := sender.EmailMessage{
		From:        ctr.config.EmailSendFrom,
		To:          request.Email,
		Subject:     "Подтвердите адрес электронной почты",
		PlainText:   plainText,
		HTMLContent: htmlContent,
	}

	// Send the email
	err = sender.SendFormattedEmail(request.Email, emailMsg, ctr.config)
	if err != nil {
		ctr.logger.Error(err.Error())
		return myerrors.GetHttpErrorByCode(myerrors.SendingEmailFailed, ctx)
	}

	return ctx.JSON(http.StatusOK, RegisterResponse{UserId: userId})
}
