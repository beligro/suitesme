package style

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"

	"github.com/aws/aws-sdk-go/service/s3"
)

type StyleController struct {
	logger   *logging.Logger
	storage  *storage.Storage
	config   *config.Config
	s3Client *s3.S3
}

func NewStyleController(logger *logging.Logger, storage *storage.Storage, config *config.Config, s3Client *s3.S3) StyleController {
	return StyleController{
		logger:   logger,
		storage:  storage,
		config:   config,
		s3Client: s3Client,
	}
}
