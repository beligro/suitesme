package api_content

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"

	"github.com/patrickmn/go-cache"
)

type ApiContentController struct {
	logger       *logging.Logger
	storage      *storage.Storage
	config       *config.Config
	contentCache *cache.Cache
}

func NewApiContentController(logger *logging.Logger, storage *storage.Storage, config *config.Config, contentCache *cache.Cache) ApiContentController {
	return ApiContentController{
		logger:       logger,
		storage:      storage,
		config:       config,
		contentCache: contentCache,
	}
}
