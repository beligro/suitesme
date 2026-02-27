package style

import (
	"net/http"
	"suitesme/internal/models"
	"suitesme/pkg/myerrors"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type StyleInfo struct {
	StyleId         string `json:"style_id"`
	PdfInfoUrl      string `json:"pdf_info_url,omitempty"`
	CanUploadPhotos bool   `json:"can_upload_photos"`
}

// Info godoc
// @Summary Get user style information
// @Description Get user's style ID and check if they can upload photos
// @Tags style
// @Accept json
// @Produce json
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} StyleInfo
// @Failure 400 {object} models.ErrorResponse
// @Failure 401 {object} models.ErrorResponse
// @Failure 403 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/v1/style/info [get]
func (ctr StyleController) Info(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")
	userID := ctx.Get("userID")
	if userID == nil {
		return myerrors.GetHttpErrorByCode(myerrors.UserUnauthorized, ctx)
	}

	parsedUserId := userID.(uuid.UUID)

	styleId, err := ctr.storage.UserStyle.Get(parsedUserId)

	if err != nil && err != gorm.ErrRecordNotFound {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Get user to check if admin
	user, err := ctr.storage.User.Get(parsedUserId)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Admin users can always upload photos
	canUploadPhotos := user.IsAdmin

	if styleId != "" {
		var pdfInfoUrl string
		if dbStyle, err := ctr.storage.Styles.GetByName(styleId); err == nil && dbStyle != nil {
			pdfInfoUrl = dbStyle.PdfInfoUrl
		}

		response := StyleInfo{
			StyleId:         styleId,
			PdfInfoUrl:      pdfInfoUrl,
			CanUploadPhotos: canUploadPhotos,
		}

		return ctx.JSON(http.StatusOK, response)
	}

	// If not admin, check payment
	if !canUploadPhotos {
		payment, err := ctr.storage.Payments.Get(parsedUserId)
		if err != nil || payment == nil || payment.Status != models.Paid {
			ctr.logger.Error("Не оплачено")
			return myerrors.GetHttpErrorByCode(myerrors.NotPaid, ctx)
		}
		// Regular users with payment can upload one photo
		canUploadPhotos = true
	}

	return myerrors.GetHttpErrorByCode(myerrors.StyleNotFound, ctx)
}
