package payment

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
)

type PaymentController struct {
	logger  *logging.Logger
	storage *storage.Storage
	config  *config.Config
}

func NewPaymentController(logger *logging.Logger, storage *storage.Storage, config *config.Config) PaymentController {
	return PaymentController{
		logger:  logger,
		storage: storage,
		config:  config,
	}
}
