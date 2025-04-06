package admin_auth

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
)

type AdminAuthController struct {
	logger  *logging.Logger
	storage *storage.Storage
	config  *config.Config
}

func NewAdminAuthController(logger *logging.Logger, storage *storage.Storage, config *config.Config) AdminAuthController {
	return AdminAuthController{
		logger:  logger,
		storage: storage,
		config:  config,
	}
}
