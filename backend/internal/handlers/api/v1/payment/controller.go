package payment

import (
	"suitesme/internal/config"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"

	"github.com/patrickmn/go-cache"
)

type PaymentController struct {
	logger        *logging.Logger
	storage       *storage.Storage
	config        *config.Config
	settingsCache *cache.Cache
}

func NewPaymentController(logger *logging.Logger, storage *storage.Storage, config *config.Config, settingsCache *cache.Cache) PaymentController {
	return PaymentController{
		logger:        logger,
		storage:       storage,
		config:        config,
		settingsCache: settingsCache,
	}
}
