package content

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
)

type ContentController struct {
	logger  *logging.Logger
	storage *storage.Storage
	config  *config.Config
}

func NewContentController(logger *logging.Logger, storage *storage.Storage, config *config.Config) ContentController {
	return ContentController{
		logger:  logger,
		storage: storage,
		config:  config,
	}
}
