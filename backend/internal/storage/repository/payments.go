package repository

import (
	"suitesme/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PaymentsRepository struct {
	db *gorm.DB
}

func NewPaymentsRepository(db *gorm.DB) *PaymentsRepository {
	return &PaymentsRepository{db: db}
}

func (repo *PaymentsRepository) Get(userId uuid.UUID) *models.DbPayments {
	payment := &models.DbPayments{UserId: userId}

	repo.db.First(payment)

	return payment
}

func (repository *PaymentsRepository) Create(payment *models.DbPayments) error {
	return repository.db.Create(payment).Error
}

func (repo *PaymentsRepository) Save(payment *models.DbPayments) {
	repo.db.Save(payment)
}
