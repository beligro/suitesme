package settings_public

import (
	"suitesme/internal/storage"
	"suitesme/pkg/logging"

	"github.com/patrickmn/go-cache"
)

type SettingsPublicController struct {
	logger        *logging.Logger
	storage       *storage.Storage
	settingsCache *cache.Cache
}

func NewSettingsPublicController(logger *logging.Logger, storage *storage.Storage, settingsCache *cache.Cache) SettingsPublicController {
	return SettingsPublicController{
		logger:        logger,
		storage:       storage,
		settingsCache: settingsCache,
	}
}
