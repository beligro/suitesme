package profile

import (
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
)

type ProfileController struct {
	logger  *logging.Logger
	storage *storage.Storage
}

func NewProfileController(logger *logging.Logger, storage *storage.Storage) ProfileController {
	return ProfileController{
		logger:  logger,
		storage: storage,
	}
}
