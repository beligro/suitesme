package styles

import (
	"fmt"
	"net/http"
	"suitesme/internal/models"
	"suitesme/pkg/myerrors"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type PostResponse struct {
	Id string `json:"id" validate:"required"`
}

type StyleRequest struct {
	Id      string `json:"id"`
	Name    string `json:"name" validate:"required"`
	Comment string `json:"comment" validate:"required"`
}

func (ctr StylesController) Post(ctx echo.Context) error {
	ctr.logger.Data["trace_id"] = ctx.Get("trace_id")

	// Parse the multipart form data
	if err := ctx.Request().ParseMultipartForm(10 << 20); err != nil { // 10 MB max
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadRequestJson, ctx)
	}

	// Extract form fields
	name := ctx.FormValue("name")
	comment := ctx.FormValue("comment")
	id := ctx.FormValue("id")

	// Validate required fields
	if name == "" || comment == "" {
		return myerrors.GetHttpErrorByCode(myerrors.ValidateJsonError, ctx)
	}

	// Generate a unique ID if not provided
	if id == "" {
		id = uuid.New().String()
	}

	// Create style data struct
	styleData := &StyleRequest{
		Id:      id,
		Name:    name,
		Comment: comment,
	}

	// Get the PDF file
	pdfFile, err := ctx.FormFile("pdf_file")
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
	}

	src, err := pdfFile.Open()
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.BadPhotoFormat, ctx)
	}
	defer src.Close()

	fileKey := fmt.Sprintf("%s/%s", styleData.Id, pdfFile.Filename)

	// Upload the PDF to S3
	_, err = ctr.s3Client.PutObject(&s3.PutObjectInput{
		Bucket:      aws.String(ctr.config.StylePdfBucket),
		Key:         aws.String(fileKey),
		Body:        src,
		ContentType: aws.String("application/pdf"),
	})
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.ExternalError, ctx)
	}

	pdfURL := fmt.Sprintf("%s/%s/%s", ctr.config.MinioFilePathEndpoint, ctr.config.StylePhotoBucket, fileKey)

	// Create the style in the database
	dbStyle := &models.DbStyle{
		Id:         styleData.Id,
		Name:       styleData.Name,
		Comment:    styleData.Comment,
		PdfInfoUrl: pdfURL,
	}

	err = ctr.storage.Styles.Create(dbStyle)
	if err != nil {
		ctr.logger.Error(err)
		return myerrors.GetHttpErrorByCode(myerrors.InternalServerError, ctx)
	}

	return ctx.JSON(http.StatusOK, PostResponse{Id: dbStyle.Id})
}
