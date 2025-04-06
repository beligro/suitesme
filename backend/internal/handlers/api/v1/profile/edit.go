package profile

import (
	"net/http"
	"suitesme/internal/models"
	utils_request "suitesme/internal/utils/request"
	"suitesme/pkg/myerrors"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

// @Summary		User profile edit
// @ID			user-profile-edit
// @Accept		json
// @Produce		json
// @Tags		user
// @Param		Authorization	header		string			   			true	"Bearer token"
// @Param		request			body		models.MutableUserFields	true	"Request"
// @Success		200				{object}	models.EmptyResponse				"ok"
// @Failure		400				{object}	models.ErrorResponse
// @Failure		404				{object}	models.ErrorResponse
// @Failure		500				{object}	models.ErrorResponse
// @Router		/api/v1/profile/edit [post]
func (ctr ProfileController) Edit(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	userID := ctx.Get("userID")
	if userID == nil {
		return myerrors.GetHttpErrorByCode(myerrors.UserUnauthorized, ctx)
	}
	parsedUserId := userID.(uuid.UUID)

	request, err := utils_request.ParseRequest[models.MutableUserFields](&ctx, ctr.logger)
	if err != nil {
		return err
	}

	err = ctr.storage.User.Update(parsedUserId, request)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadUserUpdateParams, ctx)
	}

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
