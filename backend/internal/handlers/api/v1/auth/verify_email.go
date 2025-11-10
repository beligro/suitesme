package auth

import (
	"errors"
	"net/http"
	"suitesme/pkg/myerrors"

	"suitesme/internal/models"
	"suitesme/internal/utils/external"
	utils_request "suitesme/internal/utils/request"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
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
// @Router			/api/v1/auth/verify_email [post]
func (ctr AuthController) VerifyEmail(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	request, err := utils_request.ParseRequest[VerifyEmailRequest](&ctx)
	if err != nil {
		return err
	}

	user, err := ctr.storage.User.Get(request.UserId)
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

	if user.IsVerified {
		return myerrors.GetHttpErrorByCode(myerrors.UserAlreadyVerified, ctx)
	}

	if user.VerificationCode != request.VerificationCode {
		return myerrors.GetHttpErrorByCode(myerrors.IncorrectVerificationCode, ctx)
	}

	// Try to create lead in AmoCRM, but don't fail email verification if it fails
	var leadId int = 0
	amoLeadId, err := external.CreateLead(ctr.config, ctr.logger, user)
	if err != nil {
		ctr.logger.Warn("Failed to create AmoCRM lead (non-critical): ", err.Error())
	} else if amoLeadId != nil {
		leadId = *amoLeadId
		ctr.logger.Info("Successfully created AmoCRM lead with ID: ", leadId)
	} else {
		ctr.logger.Warn("Empty lead id from AmoCRM (non-critical)")
	}

	ctr.storage.User.SetUserIsVerified(request.UserId, leadId)

	return ctx.JSON(http.StatusOK, models.EmptyResponse{})
}
