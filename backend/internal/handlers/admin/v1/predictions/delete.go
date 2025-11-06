package predictions

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

func (ctr PredictionsController) Delete(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id := ctx.Param("id")
	parsedId, err := uuid.Parse(id)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadQueryParameter, ctx)
	}

	// Check if the prediction exists
	_, err = ctr.storage.UserStyle.GetById(parsedId)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			ctr.logger.Info("Prediction not found")
			return myerrors.GetHttpErrorByCode(myerrors.PredictionNotFound, ctx)
		}
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Delete the prediction
	err = ctr.storage.UserStyle.Delete(parsedId)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	return ctx.NoContent(http.StatusNoContent)
}

