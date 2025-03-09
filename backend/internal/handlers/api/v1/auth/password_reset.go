package auth

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"suitesme/internal/models"
	utils_request "suitesme/internal/utils/request"
	"suitesme/internal/utils/security"

	"github.com/labstack/echo/v4"
)

type PasswordResetRequest struct {
	ResetToken      string `json:"reset_token" validate:"required"`
	Password        string `json:"password" validate:"required"`
	PasswordConfirm string `json:"password_confirm" validate:"required"`
}

// @Summary		Reset password
// @Description	Reset password
// @ID			auth-password-reset
// @Accept		json
// @Produce		json
// @Tags		auth
// @Param		request	body		PasswordResetRequest			true	"Request"
// @Success		200		{object}	models.EmptyResponse		"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		404		{object}	models.ErrorResponse
// @Failure		409		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/auth/password/reset [post]
func (ctr AuthController) PasswordReset(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	request, err := utils_request.ParseRequest[PasswordResetRequest](&ctx, ctr.logger)
	if err != nil {
		return err
	}

	if request.Password != request.PasswordConfirm {
		ctr.logger.Warn("Passwords are different")
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	resetInfo, err := security.Decode(request.ResetToken)

	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	user, err := ctr.storage.User.GetForPasswordReset(resetInfo.UserId, resetInfo.ResetToken)

	if err != nil || user == nil {
		return myerrors.GetHttpErrorByCode(http.StatusUnauthorized)
	}

	passwordHash, err := security.HashPassword(request.Password)
	if err != nil {
		ctr.logger.Error(err.Error())
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	user.PasswordHash = string(passwordHash)
	user.PasswordResetToken = ""

	ctr.storage.User.Save(user)

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
