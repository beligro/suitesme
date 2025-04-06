package content

import (
	"net/http"
	"strconv"
	"suitesme/internal/models"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

func (ctr ContentController) Delete(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctr.logger.Info("Not found id in path")
		return myerrors.GetHttpErrorByCode(myerrors.BadIdInPath, ctx)
	}

	dbContent := &models.DbWebContent{
		ID: id,
	}

	ctr.storage.WebContent.Delete(dbContent)

	return ctx.JSON(http.StatusOK, dbContent)
}
