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

	msg := []byte("Password reset url is: http://51.250.84.195:3000/password_reset?token=" + urlToken)
	err = sender.SendEmail(request.Email, msg, ctr.config)

	if err != nil {
		ctr.logger.Error(err.Error())
		return myerrors.GetHttpErrorByCode(myerrors.SendingEmailFailed, ctx)
	}

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
