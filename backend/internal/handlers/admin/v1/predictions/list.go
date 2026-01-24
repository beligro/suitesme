package predictions

import (
	"net/http"
	"suitesme/internal/storage/repository"
	"suitesme/pkg/myerrors"
	"strconv"

	"github.com/labstack/echo/v4"
)

type ListResponse struct {
	Data  interface{} `json:"data"`
	Total int64       `json:"total"`
}

func (ctr PredictionsController) List(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	// Parse query parameters
	limitStr := ctx.QueryParam("_end")
	offsetStr := ctx.QueryParam("_start")
	sortBy := ctx.QueryParam("_sort")
	sortOrder := ctx.QueryParam("_order")
	isVerifiedStr := ctx.QueryParam("isVerified")

	limit := 10
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil {
			limit = l
		}
	}

	offset := 0
	if offsetStr != "" {
		if o, err := strconv.Atoi(offsetStr); err == nil {
			offset = o
		}
	}

	// Calculate actual limit and offset for react-admin
	actualLimit := limit - offset
	if actualLimit <= 0 {
		actualLimit = 10
	}

	// Convert camelCase sort field to snake_case for database
	dbSortBy := sortBy
	switch sortBy {
	case "createdAt":
		dbSortBy = "created_at"
	case "updatedAt":
		dbSortBy = "updated_at"
	case "userId":
		dbSortBy = "user_id"
	case "styleId":
		dbSortBy = "style_id"
	case "initialPrediction":
		dbSortBy = "initial_prediction"
	case "verifiedPrediction":
		dbSortBy = "style_id" // legacy: verifiedPrediction is stored in style_id
	case "isVerified":
		dbSortBy = "is_verified"
	case "verifiedBy":
		dbSortBy = "verified_by"
	case "verifiedAt":
		dbSortBy = "verified_at"
	}

	params := repository.PredictionListParams{
		Limit:     actualLimit,
		Offset:    offset,
		SortBy:    dbSortBy,
		SortOrder: sortOrder,
	}

	// Handle verified filter
	if isVerifiedStr != "" {
		isVerified := isVerifiedStr == "true"
		params.IsVerified = &isVerified
	}

	predictions, total, err := ctr.storage.UserStyle.List(params)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Set X-Total-Count header for react-admin json-server provider
	ctx.Response().Header().Set("X-Total-Count", strconv.FormatInt(total, 10))
	ctx.Response().Header().Set("Access-Control-Expose-Headers", "X-Total-Count")

	return ctx.JSON(http.StatusOK, predictions)
}

