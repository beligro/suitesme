package settings

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
)

type SettingsController struct {
	logger  *logging.Logger
	storage *storage.Storage
	config  *config.Config
}

func NewSettingsController(logger *logging.Logger, storage *storage.Storage, config *config.Config) SettingsController {
	return SettingsController{
		logger:  logger,
		storage: storage,
		config:  config,
	}
}
