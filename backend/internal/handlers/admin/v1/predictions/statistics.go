package predictions

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

func (ctr PredictionsController) Statistics(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	stats, err := ctr.storage.UserStyle.GetStatistics()
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	return ctx.JSON(http.StatusOK, stats)
}

