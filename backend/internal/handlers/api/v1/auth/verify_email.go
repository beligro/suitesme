package auth

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"suitesme/internal/models"
	"suitesme/internal/utils/external"
	utils_request "suitesme/internal/utils/request"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type VerifyEmailRequest struct {
	UserId           uuid.UUID `json:"user_id" validate:"required"`
	VerificationCode string    `json:"verification_code" validate:"required"`
}

// @Summary		Verify user email
// @Description	Verify user email
// @ID			auth-verify-email
// @Accept		json
// @Produce		json
// @Tags		auth
// @Param		request	body		VerifyEmailRequest			true	"Request"
// @Success		200		{object}	models.EmptyResponse		"ok"
// @Failure		400		{object}	models.ErrorResponse
// @Failure		404		{object}	models.ErrorResponse
// @Failure		409		{object}	models.ErrorResponse
// @Failure		500		{object}	models.ErrorResponse
// @Router			/api/v1/auth/email/verify [post]
func (ctr AuthController) VerifyEmail(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	request, err := utils_request.ParseRequest[VerifyEmailRequest](&ctx, ctr.logger)
	if err != nil {
		return err
	}

	user, err := ctr.storage.User.Get(request.UserId)

	if err != nil {
		ctr.logger.Error(err)
		return myerrors.ParseGormErrorToHttp(err)
	}

	if user == nil {
		return myerrors.GetHttpErrorByCode(http.StatusNotFound)
	}

	if user.IsVerified {
		return myerrors.GetHttpErrorByCode(http.StatusConflict)
	}

	if user.VerificationCode != request.VerificationCode {
		return myerrors.GetHttpErrorByCode(http.StatusConflict)
	}

	leadId, err := external.CreateLead(ctr.config, ctr.logger, user)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}
	if leadId == nil {
		ctr.logger.Error("Empty lead id")
		return myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	err = ctr.storage.User.SetUserIsVerified(request.UserId, *leadId)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.ParseGormErrorToHttp(err)
	}

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
