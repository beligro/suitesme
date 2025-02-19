package repository

import (
	"suitesme/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type TokensRepository struct {
	db *gorm.DB
}

func NewTokensRepository(db *gorm.DB) *TokensRepository {
	return &TokensRepository{db: db}
}

func (repository *TokensRepository) CreateToken(token *models.DbTokens) error {
	return repository.db.Create(&token).Error
}

func (repository *TokensRepository) DeleteTokens(userId uuid.UUID) error {
	return repository.db.Model(&models.DbTokens{UserId: userId}).Update("is_removed", "true").Error
}

func (repository *TokensRepository) GetByUserId(userId uuid.UUID) (*models.DbTokens, error) {
	tokenInfo := models.DbTokens{}

	result := repository.db.Where("user_id = ?", userId).First(&tokenInfo)

	if err := result.Error; err != nil {
		return nil, err
	}

	return &tokenInfo, nil
}

func (repository *TokensRepository) GetByPK(userId uuid.UUID, refreshToken string) (*models.DbTokens, error) {
	tokenInfo := models.DbTokens{}

	result := repository.db.Where("user_id = ? AND refresh_token = ? AND NOT is_removed", userId, refreshToken).First(&tokenInfo)

	if err := result.Error; err != nil {
		return nil, err
	}

	return &tokenInfo, nil
}
