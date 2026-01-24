package predictions

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
)

type PredictionsController struct {
	logger  *logging.Logger
	storage *storage.Storage
	config  *config.Config
}

func NewPredictionsController(logger *logging.Logger, storage *storage.Storage, config *config.Config) PredictionsController {
	return PredictionsController{
		logger:  logger,
		storage: storage,
		config:  config,
	}
}

