package settings

import (
	"net/http"
	"strconv"
	"suitesme/internal/models"
	utils_request "suitesme/internal/utils/request"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

func (ctr SettingsController) Put(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctr.logger.Info("Not found id in path")
		return myerrors.GetHttpErrorByCode(myerrors.BadIdInPath, ctx)
	}

	setting, err := utils_request.ParseRequest[models.UpsertSettingRequest](&ctx, ctr.logger)
	if err != nil {
		return err
	}

	dbSetting := &models.DbSettings{
		ID:    id,
		Key:   setting.Key,
		Value: setting.Value,
	}

	ctr.storage.Settings.Save(dbSetting)

	return ctx.JSON(http.StatusOK, dbSetting)
}
