package api_content

import (
	"net/http"
	"suitesme/internal/caches"

	"github.com/labstack/echo/v4"
)

func (ctr ApiContentController) List(ctx echo.Context) error {

	return ctx.JSON(http.StatusOK, caches.GetWebContentCache(ctr.storage, ctr.contentCache))
}
