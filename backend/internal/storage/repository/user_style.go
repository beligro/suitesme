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
	var userStyle models.DbUserStyle

	// Order by created_at desc to get the latest style
	result := repo.db.Where("user_id = ?", userId).Order("created_at desc").First(&userStyle)

	return userStyle.StyleId, result.Error
}

func (repository *UserStyleRepository) Create(userStyle *models.DbUserStyle) {
	repository.db.Create(&userStyle)
}
