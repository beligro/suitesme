package repository

import (
	"suitesme/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserStyleRepository struct {
	db *gorm.DB
}

func NewUserStyleRepository(db *gorm.DB) *UserStyleRepository {
	return &UserStyleRepository{db: db}
}

func (repo *UserStyleRepository) Get(userId uuid.UUID) (string, error) {
	user := &models.DbUserStyle{UserId: userId}

	result := repo.db.First(user)

	return user.StyleId, result.Error
}

func (repository *UserStyleRepository) Create(userStyle *models.DbUserStyle) error {
	return repository.db.Create(&userStyle).Error
}
