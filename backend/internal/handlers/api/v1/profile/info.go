package profile

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type ProfileInfo struct {
	Email     string `json:"email" validate:"required,email"`
	FirstName string `json:"first_name" validate:"required"`
	LastName  string `json:"last_name" validate:"required"`
	BirthDate string `json:"birth_date" validate:"required"`
}

// @Summary		User profile info
// @ID			user-profile-info
// @Accept		json
// @Produce		json
// @Tags		user
// @Param		Authorization	header		string	true			"Bearer token"
// @Success		200				{object}	models.UserInfoResponse	"ok"
// @Failure		400				{object}	models.ErrorResponse
// @Failure		404				{object}	models.ErrorResponse
// @Failure		500				{object}	models.ErrorResponse
// @Router		/api/v1/profile/info [get]
func (ctr ProfileController) Info(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	userID := ctx.Get("userID")
	if userID == nil {
		return myerrors.GetHttpErrorByCode(http.StatusUnauthorized)
	}

	parsedUserId := userID.(uuid.UUID)

	user, err := ctr.storage.User.Get(parsedUserId)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.ParseGormErrorToHttp(err)
	}

	if user == nil {
		return myerrors.GetHttpErrorByCode(http.StatusNotFound)
	}

	response := ProfileInfo{
		Email:     user.Email,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		BirthDate: user.BirthDate,
	}

	return ctx.JSON(http.StatusOK, response)
}
