package content

import (
	"net/http"
	"suitesme/internal/models"
	utils_request "suitesme/internal/utils/request"

	"github.com/labstack/echo/v4"
)

type PostResponse struct {
	Id int `json:"id" validate:"required"`
}

func (ctr ContentController) Post(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	content, err := utils_request.ParseRequest[models.UpsertContentRequest](&ctx)
	if err != nil {
		return err
	}

	dbContent := &models.DbWebContent{
		Key:     content.Key,
		RuValue: content.RuValue,
		EnValue: content.EnValue,
	}

	ctr.storage.WebContent.Create(dbContent)

	return ctx.JSON(http.StatusOK, PostResponse{Id: dbContent.ID})
}
