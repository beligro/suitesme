package settings

import (
	"fmt"
	"net/http"
	"strconv"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

func (ctr SettingsController) List(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	start, err := strconv.Atoi(ctx.QueryParam("_start"))
	if err != nil {
		ctr.logger.Info("Start query param is not integer")
		return myerrors.GetHttpErrorByCode(myerrors.BadQueryParameter, ctx)
	}
	end, err := strconv.Atoi(ctx.QueryParam("_end"))
	if err != nil {
		ctr.logger.Info("End query param is not integer")
		return myerrors.GetHttpErrorByCode(myerrors.BadQueryParameter, ctx)
	}

	sort := ctx.QueryParam("_sort")
	order := ctx.QueryParam("_order")
	if sort == "" {
		sort = "id"
	}
	if order == "" {
		order = "ASC"
	}

	limit := end - start
	offset := start

	settings := ctr.storage.Settings.List(sort, order, limit, offset)

	ctx.Response().Header().Set("X-Total-Count", fmt.Sprintf("%d", ctr.storage.Settings.Count()))
	ctx.Response().Header().Set("Access-Control-Expose-Headers", "X-Total-Count")

	return ctx.JSON(http.StatusOK, settings)
}
