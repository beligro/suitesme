package auth

import (
	"net/http"
	"suitesme/internal/models"
	utils_request "suitesme/internal/utils/request"
	"suitesme/internal/utils/security"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

type LogoutRequest struct {
	RefreshToken *string `json:"refresh_token" validate:"required"`
}

// @Summary			Logout user
// @ID				auth-logout
// @Accept			json
// @Produce			json
// @Tags			auth
// @Param			request	body	LogoutRequest			true	"Request"
// @Success	200		{object}		models.EmptyResponse	"ok"
// @Failure	400		{object}		models.ErrorResponse
// @Failure	500		{object}		models.ErrorResponse
// @Router		/api/v1/auth/logout [post]
func (ctr AuthController) Logout(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	request, err := utils_request.ParseRequest[LogoutRequest](&ctx, ctr.logger)
	if err != nil {
		return err
	}

	claims, err := security.ParseToken(*request.RefreshToken, ctr.config.RefreshTokenSecret)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	err = ctr.storage.Tokens.DeleteTokens(claims.UserId)

	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusInternalServerError)
	}

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
