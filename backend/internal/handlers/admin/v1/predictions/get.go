package predictions

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

func (ctr PredictionsController) Get(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id := ctx.Param("id")
	parsedId, err := uuid.Parse(id)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadRequestJson, ctx)
	}

	prediction, err := ctr.storage.UserStyle.GetById(parsedId)
	if err == gorm.ErrRecordNotFound {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.PredictionNotFound, ctx)
	}
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	return ctx.JSON(http.StatusOK, prediction)
}

