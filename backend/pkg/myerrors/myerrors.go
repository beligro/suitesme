package myerrors

import (
	"errors"
	"fmt"
	"net/http"
	"suitesme/pkg/types"

	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type HTTPError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func Error(err error, ctx echo.Context) {
	errObj := HTTPError{
		Code:    http.StatusInternalServerError,
		Message: err.Error(),
	}
	switch err {
	case types.ErrBadRequest:
		errObj.Code = http.StatusBadRequest
	case types.ErrNotFound:
		errObj.Code = http.StatusNotFound
	case types.ErrDuplicateEntry, types.ErrConflict:
		errObj.Code = http.StatusConflict
	case types.ErrForbidden:
		errObj.Code = http.StatusForbidden
	case types.ErrUnprocessableEntity:
		errObj.Code = http.StatusUnprocessableEntity
	case types.ErrPartialOk:
		errObj.Code = http.StatusPartialContent
	case types.ErrGone:
		errObj.Code = http.StatusGone
	case types.ErrUnauthorized:
		errObj.Code = http.StatusUnauthorized
	case types.ErrConflict:
		errObj.Code = http.StatusConflict
	}
	he, ok := err.(*echo.HTTPError)
	if ok {
		errObj.Code = he.Code
		errObj.Message = fmt.Sprintf("%v", he.Message)
	}
	if !ctx.Response().Committed {
		if ctx.Request().Method == echo.HEAD {
			ctx.NoContent(errObj.Code)
		} else {
			ctx.JSON(errObj.Code, errObj)
		}
	}
}

func ParseGormErrorToHttp(err error) *echo.HTTPError {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return echo.NewHTTPError(http.StatusNotFound, http.StatusText(http.StatusNotFound))
	}
	if errors.Is(err, gorm.ErrDuplicatedKey) {
		return echo.NewHTTPError(http.StatusConflict, http.StatusText(http.StatusConflict))
	}
	return echo.NewHTTPError(http.StatusInternalServerError, http.StatusText(http.StatusInternalServerError))
}

func GetHttpErrorByCode(errorCode int) *echo.HTTPError {
	return echo.NewHTTPError(errorCode, http.StatusText(errorCode))
}
