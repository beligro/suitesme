package settings_public

import (
	"net/http"
	"suitesme/internal/caches"

	"github.com/labstack/echo/v4"
)

type PublicSettingsResponse struct {
	Price    string  `json:"price"`
	OldPrice *string `json:"old_price,omitempty"`
}

func (ctr SettingsPublicController) GetPublic(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	settingsCache := caches.GetSettingsCache(ctr.storage, ctr.settingsCache)

	response := PublicSettingsResponse{
		Price: settingsCache["price"],
	}

	if oldPrice, exists := settingsCache["old_price"]; exists && oldPrice != "" {
		response.OldPrice = &oldPrice
	}

	return ctx.JSON(http.StatusOK, response)
}
