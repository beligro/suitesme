package request

import (
	"net/http"
	"suitesme/pkg/logging"
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

func ParseRequest[T any](ctx *echo.Context, logger *logging.Logger) (*T, error) {
	var request T

	err := (*ctx).Bind(&request)
	if err != nil {
		logger.Warn(err)
		return nil, myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	err = (*ctx).Validate(&request)
	if err != nil {
		logger.Warn(err)
		return nil, myerrors.GetHttpErrorByCode(http.StatusBadRequest)
	}

	return &request, nil
}
