package auth

import (
	"errors"
	"net/http"
	utils_request "suitesme/internal/utils/request"
	"suitesme/internal/utils/security"
	"suitesme/pkg/myerrors"
	"time"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type RefreshRequest struct {
	RefreshToken *string `json:"refresh_token" validate:"required"`
}

// @Summary			Refresh tokens
// @ID				auth-refresh
// @Accept			json
// @Produce			json
// @Tags			auth
// @Param			request	body	RefreshRequest			true	"Request"
// @Success	200		{object}		models.TokensResponse	"ok"
// @Failure	400		{object}		models.ErrorResponse
// @Failure	401		{object}		models.ErrorResponse
// @Failure	403		{object}		models.ErrorResponse
// @Failure	500		{object}		models.ErrorResponse
// @Router		/api/v1/auth/refresh [post]
func (ctr AuthController) Refresh(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	request, err := utils_request.ParseRequest[RefreshRequest](&ctx, ctr.logger)
	if err != nil {
		return err
	}

	claims, err := security.ParseToken(*request.RefreshToken, ctr.config.RefreshTokenSecret)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	_, err = ctr.storage.Tokens.GetByPK((*claims).UserId, *request.RefreshToken)
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			ctr.logger.Error(err)
			return myerrors.GetHttpErrorByCode(http.StatusInternalServerError)
		}

		err = ctr.storage.Tokens.DeleteTokens((*claims).UserId)
		if err != nil {
			ctr.logger.Error(err)
			return myerrors.GetHttpErrorByCode(http.StatusInternalServerError)
		}
		return echo.NewHTTPError(http.StatusBadRequest, "refresh token is invalid")
	}

	if claims.ExpiresAt.Time.Before(time.Now()) {
		return myerrors.GetHttpErrorByCode(http.StatusUnauthorized)
	}

	err = ctr.storage.Tokens.DeleteTokens(claims.UserId)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusInternalServerError)
	}

	response, httpErr := security.GenerateTokens(claims.UserId, ctr.config, ctr.storage)

	if httpErr != nil {
		return httpErr
	}

	return ctx.JSON(http.StatusOK, &response)
}
