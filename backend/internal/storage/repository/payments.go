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

func (repo *PaymentsRepository) Get(userId uuid.UUID) (*models.DbPayments, error) {
	payment := &models.DbPayments{UserId: userId}

	err := repo.db.First(payment).Error

	return payment, err
}

func (repository *PaymentsRepository) Create(payment *models.DbPayments) {
	repository.db.Create(payment)
}

func (repo *PaymentsRepository) Save(payment *models.DbPayments) {
	repo.db.Save(payment)
}
