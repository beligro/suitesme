package auth

import (
	"errors"
	"net/http"
	"suitesme/internal/utils/security"
	"suitesme/pkg/myerrors"

	utils_request "suitesme/internal/utils/request"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

// @Summary		Login user
// @Description	Login user and return tokens
// @ID			auth-login
// @Accept		json
// @Produce		json
// @Tags		auth
// @Param		request	body		LoginRequest			true	"Request"
// @Success		200		{object}	models.TokensResponse	"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		404		{object}	models.ErrorResponse
// @Failure		409		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/auth/login [post]
func (ctr AuthController) Login(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	request, err := utils_request.ParseRequest[LoginRequest](&ctx)
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
	if user == nil {
		return myerrors.GetHttpErrorByCode(myerrors.UserNotFound, ctx)
	}
	if !user.IsVerified {
		return myerrors.GetHttpErrorByCode(myerrors.UserNotFound, ctx)
	}

	err = security.ComparePasswordWithHash(request.Password, user.PasswordHash)
	if err != nil {
		return myerrors.GetHttpErrorByCode(myerrors.IncorrectPassword, ctx)
	}

	response, httpErr := security.GenerateTokens(user.ID, ctr.config, ctr.storage, ctx)

	if httpErr != nil {
		return httpErr
	}

	return ctx.JSON(http.StatusOK, &response)
}
