package settings

import (
	"net/http"
	"strconv"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

func (ctr SettingsController) Get(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctr.logger.Info("Not found id in path")
		return myerrors.GetHttpErrorByCode(myerrors.BadIdInPath, ctx)
	}

	setting, err := ctr.storage.Settings.Get(id)
	if err != nil {
		return myerrors.GetHttpErrorByCode(myerrors.SettingsNotFound, ctx)
	}

	return ctx.JSON(http.StatusOK, setting)
}
