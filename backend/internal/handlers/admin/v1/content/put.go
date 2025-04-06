package content

import (
	"net/http"
	"strconv"
	"suitesme/internal/models"
	utils_request "suitesme/internal/utils/request"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

func (ctr ContentController) Put(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctr.logger.Info("Not found id in path")
		return myerrors.GetHttpErrorByCode(myerrors.BadIdInPath, ctx)
	}

	content, err := utils_request.ParseRequest[models.UpsertContentRequest](&ctx, ctr.logger)
	if err != nil {
		return err
	}

	dbContent := &models.DbWebContent{
		ID:      id,
		Key:     content.Key,
		RuValue: content.RuValue,
		EnValue: content.EnValue,
	}

	ctr.storage.WebContent.Save(dbContent)

	return ctx.JSON(http.StatusOK, dbContent)
}
