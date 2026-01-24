package predictions

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type VerifyRequest struct {
	StyleId            string `json:"styleId"`
	VerifiedPrediction string `json:"verifiedPrediction"` // legacy support
}

func (ctr PredictionsController) Put(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id := ctx.Param("id")
	parsedId, err := uuid.Parse(id)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadRequestJson, ctx)
	}

	var req VerifyRequest
	if err := ctx.Bind(&req); err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadRequestJson, ctx)
	}

	// Use styleId if provided, otherwise fall back to verifiedPrediction for legacy support
	verifiedStyle := req.StyleId
	if verifiedStyle == "" {
		verifiedStyle = req.VerifiedPrediction
	}

	if verifiedStyle == "" {
		ctr.logger.Error("styleId or verifiedPrediction is required")
		return myerrors.GetHttpErrorByCode(myerrors.ValidateJsonError, ctx)
	}

	// Get admin username from context (set by AdminJWTAuthMiddleware)
	adminUsername := ctx.Get("adminUsername")
	if adminUsername == nil {
		return myerrors.GetHttpErrorByCode(myerrors.UserUnauthorized, ctx)
	}

	// Get admin user from database
	adminUser, err := ctr.storage.AdminUser.GetByUsername(adminUsername.(string))
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.UserUnauthorized, ctx)
	}

	// Update style with verification
	err = ctr.storage.UserStyle.Verify(parsedId, verifiedStyle, adminUser.ID)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Return updated style
	style, err := ctr.storage.UserStyle.GetById(parsedId)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	return ctx.JSON(http.StatusOK, style)
}

