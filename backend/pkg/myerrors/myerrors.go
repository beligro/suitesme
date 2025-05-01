package myerrors

import (
	"fmt"
	"net/http"
	"suitesme/pkg/types"

	"github.com/labstack/echo/v4"
)

type HTTPError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

type MyError struct {
	Code    string `json:"code" validate:"required"`
	Message string `json:"message" validate:"required"`
}

type ErrorCode string

const (
	BadIdInPath       ErrorCode = "bad_id_in_path"
	BadQueryParameter ErrorCode = "bad_query_parameter"
	BadPhotoFormat    ErrorCode = "bad_photo_format"
	BadRequestJson    ErrorCode = "bad_request_json"
	ValidateJsonError ErrorCode = "validate_json_error"

	ContentNotFound  ErrorCode = "content_not_found"
	SettingsNotFound ErrorCode = "settings_not_found"
	UserNotFound     ErrorCode = "user_not_found"
	PaymentNotFound  ErrorCode = "payment_not_found"
	StyleNotFound    ErrorCode = "style_not_found"

	UserUnauthorized          ErrorCode = "user_unauthorized"
	UserNotExists             ErrorCode = "user_not_exists"
	UserAlreadyExists         ErrorCode = "user_already_exists"
	UserAlreadyVerified       ErrorCode = "user_already_verified"
	IncorrectPassword         ErrorCode = "incorrect_password"
	DifferrentPasswords       ErrorCode = "different_passwords"
	IncorrectToken            ErrorCode = "incorrect_token"
	IncorrectVerificationCode ErrorCode = "incorrect_verification_code"
	IncorrectSign             ErrorCode = "incorrect_sign"
	BadUserUpdateParams       ErrorCode = "bad_user_update_params"

	InternalServerError ErrorCode = "internal_server_error"
	ExternalError       ErrorCode = "external_error"
	SendingEmailFailed  ErrorCode = "sending_email_failed"

	DifferentPaymentSum ErrorCode = "different_payment_sum"
	AlreadyPaid         ErrorCode = "already_paid"
	NotPaid             ErrorCode = "not_paid"
)

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

func GetHttpErrorByCode(errorCode ErrorCode, ctx echo.Context) error {
	switch errorCode {
	case BadIdInPath:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Bad id in path"})
	case BadQueryParameter:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Bad query parameter"})
	case BadPhotoFormat:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Bad photo format"})
	case BadRequestJson:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Bad request json"})
	case ValidateJsonError:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Request json validation error"})
	case IncorrectPassword:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Неверный пароль"})
	case IncorrectToken:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Incorrect token"})
	case UserAlreadyVerified:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "User already verified"})
	case IncorrectSign:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Incorrect sign"})
	case BadUserUpdateParams:
		return ctx.JSON(http.StatusBadRequest, MyError{Code: string(errorCode), Message: "Bad user update params"})

	case UserUnauthorized:
		return ctx.JSON(http.StatusUnauthorized, MyError{Code: string(errorCode), Message: "User is unauthorized"})
	case UserNotExists:
		return ctx.JSON(http.StatusUnauthorized, MyError{Code: string(errorCode), Message: "User not exists"})

	case NotPaid:
		return ctx.JSON(http.StatusForbidden, MyError{Code: string(errorCode), Message: "Not paid"})

	case ContentNotFound:
		return ctx.JSON(http.StatusNotFound, MyError{Code: string(errorCode), Message: "Content not found"})
	case SettingsNotFound:
		return ctx.JSON(http.StatusNotFound, MyError{Code: string(errorCode), Message: "Settings not found"})
	case UserNotFound:
		return ctx.JSON(http.StatusNotFound, MyError{Code: string(errorCode), Message: "User not found"})
	case StyleNotFound:
		return ctx.JSON(http.StatusNotFound, MyError{Code: string(errorCode), Message: "Style not found"})
	case PaymentNotFound:
		return ctx.JSON(http.StatusNotFound, MyError{Code: string(errorCode), Message: "Payment not found"})

	case UserAlreadyExists:
		return ctx.JSON(http.StatusConflict, MyError{Code: string(errorCode), Message: "User already exists"})
	case DifferrentPasswords:
		return ctx.JSON(http.StatusConflict, MyError{Code: string(errorCode), Message: "Different passwords"})
	case IncorrectVerificationCode:
		return ctx.JSON(http.StatusConflict, MyError{Code: string(errorCode), Message: "Incorrect verification code"})
	case DifferentPaymentSum:
		return ctx.JSON(http.StatusConflict, MyError{Code: string(errorCode), Message: "Different payment sum"})
	case AlreadyPaid:
		return ctx.JSON(http.StatusConflict, MyError{Code: string(errorCode), Message: "Already paid"})

	case SendingEmailFailed:
		return ctx.JSON(http.StatusInternalServerError, MyError{Code: string(errorCode), Message: "Sending email failed"})
	case ExternalError:
		return ctx.JSON(http.StatusInternalServerError, MyError{Code: string(errorCode), Message: "External error"})
	case InternalServerError:
		return ctx.JSON(http.StatusInternalServerError, MyError{Code: "internal_server_error", Message: "Internal server error"})
	default:
		return ctx.JSON(http.StatusInternalServerError, MyError{Code: "internal_server_error", Message: "Internal server error"})
	}
}
