package settings

import (
	"net/http"
	"suitesme/internal/models"
	utils_request "suitesme/internal/utils/request"

	"github.com/labstack/echo/v4"
)

type PostResponse struct {
	Id int `json:"id" validate:"required"`
}

func (ctr SettingsController) Post(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	setting, err := utils_request.ParseRequest[models.UpsertSettingRequest](&ctx)
	if err != nil {
		return err
	}

	dbSetting := &models.DbSettings{
		Key:   setting.Key,
		Value: setting.Value,
	}

	ctr.storage.Settings.Create(dbSetting)

	return ctx.JSON(http.StatusOK, PostResponse{Id: dbSetting.ID})
}
