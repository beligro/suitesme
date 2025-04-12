package admin_auth

import (
	"net/http"
	utils_request "suitesme/internal/utils/request"
	"suitesme/internal/utils/security"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

type LoginRequest struct {
	Username string `json:"username" validate:"required"`
	Password string `json:"password" validate:"required"`
}

type LoginResponse struct {
	Token string `json:"token" validate:"required"`
}

func (ctr AdminAuthController) Login(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	request, err := utils_request.ParseRequest[LoginRequest](&ctx)
	if err != nil {
		return err
	}

	user, err := ctr.storage.AdminUser.Get(request.Username, request.Password)
	if err != nil {
		return myerrors.GetHttpErrorByCode(myerrors.UserNotExists, ctx)
	}

	token, err := security.GenerateAdminToken(user.Username, ctr.config.AdminTokenSecret)
	if err != nil {
		return err
	}

	return ctx.JSON(http.StatusOK, LoginResponse{
		Token: token,
	})
}
