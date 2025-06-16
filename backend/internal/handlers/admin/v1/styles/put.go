package styles

import (
	"fmt"
	"net/http"
	"suitesme/internal/models"
	utils_request "suitesme/internal/utils/request"
	"suitesme/pkg/myerrors"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

func (ctr StylesController) Put(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	id := ctx.Param("id")
	if id == "" {
		ctr.logger.Info("ID is empty")
		return myerrors.GetHttpErrorByCode(myerrors.BadQueryParameter, ctx)
	}

	// Get the existing style
	existingStyle, err := ctr.storage.Styles.Get(id)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			ctr.logger.Info("Style not found")
			return myerrors.GetHttpErrorByCode(myerrors.StyleNotFound, ctx)
		}
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Parse the form data
	styleData, err := utils_request.ParseRequest[StyleRequest](&ctx)
	if err != nil {
		return err
	}

	// Update the style fields
	existingStyle.Name = styleData.Name
	existingStyle.Comment = styleData.Comment

	// Check if a new PDF file was uploaded
	pdfFile, err := ctx.FormFile("pdf_file")
	if err == nil {
		// A new PDF file was uploaded
		src, err := pdfFile.Open()
		if err != nil {
			ctr.logger.Error(err)
			return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
		}
		defer src.Close()

		fileKey := fmt.Sprintf("styles/%s/%s", id, pdfFile.Filename)

		// Upload the PDF to S3
		_, err = ctr.s3Client.PutObject(&s3.PutObjectInput{
			Bucket:      aws.String(ctr.config.StylePhotoBucket),
			Key:         aws.String(fileKey),
			Body:        src,
			ContentType: aws.String("application/pdf"),
		})
		if err != nil {
			ctr.logger.Error(err)
			return myerrors.GetHttpErrorByCode(myerrors.ExternalError, ctx)
		}

		pdfURL := fmt.Sprintf("%s/%s/%s", ctr.config.MinioFilePathEndpoint, ctr.config.StylePhotoBucket, fileKey)
		existingStyle.PdfInfoUrl = pdfURL
	}

	// Update the style in the database
	err = ctr.storage.Styles.Update(existingStyle)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	// Create a dummy style to ensure models package is used
	_ = &models.DbStyle{}

	return ctx.JSON(http.StatusOK, existingStyle)
}
