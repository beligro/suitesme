package request

import (
	"suitesme/pkg/myerrors"

	"github.com/labstack/echo/v4"
)

func ParseRequest[T any](ctx *echo.Context) (*T, error) {
	var request T

	err := (*ctx).Bind(&request)
	if err != nil {
		myErr := myerrors.GetHttpErrorByCode(myerrors.BadRequestJson, *ctx)
		return nil, myErr
	}

	err = (*ctx).Validate(&request)
	if err != nil {
		return nil, myerrors.GetHttpErrorByCode(myerrors.ValidateJsonError, *ctx)
	}

	return &request, nil
}
