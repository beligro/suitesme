package styles

import (
	"net/http"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

func (ctr StylesController) Get(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id := ctx.Param("id")
	if id == "" {
		ctr.logger.Info("ID is empty")
		return myerrors.GetHttpErrorByCode(myerrors.BadQueryParameter, ctx)
	}

	style, err := ctr.storage.Styles.Get(id)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			ctr.logger.Info("Style not found")
			return myerrors.GetHttpErrorByCode(myerrors.StyleNotFound, ctx)
		}
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	return ctx.JSON(http.StatusOK, style)
}
