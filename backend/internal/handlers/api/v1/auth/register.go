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
	request, err := utils_request.ParseRequest[RegisterRequest](&ctx, ctr.logger)
	if err != nil {
		return err
	}

	if request.Password != request.PasswordConfirm {
		ctr.logger.Warn("Passwords are different")
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	userExists := ctr.storage.User.CheckVerifiedUserExists(request.Email)

	if userExists {
		return myerrors.GetHttpErrorByCode(http.StatusConflict)
	}

	verificationCode := security.GetVerificationCode()
	passwordHash, err := security.HashPassword(request.Password)
	if err != nil {
		ctr.logger.Error(err.Error())
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
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

	userId, err := ctr.storage.User.Create(newUser)

	if err != nil {
		ctr.logger.Error(err.Error())
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	msg := []byte("Verification code is: " + verificationCode)
	err = sender.SendEmail(request.Email, msg, ctr.config)

	if err != nil {
		ctr.logger.Error(err.Error())
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	return ctx.JSON(http.StatusOK, RegisterResponse{UserId: userId})
}
