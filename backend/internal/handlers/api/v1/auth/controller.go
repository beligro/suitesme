package auth

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
)

type AuthController struct {
	logger  *logging.Logger
	storage *storage.Storage
	config  *config.Config
}

func NewAuthController(logger *logging.Logger, storage *storage.Storage, config *config.Config) AuthController {
	return AuthController{
		logger:  logger,
		storage: storage,
		config:  config,
	}
}
