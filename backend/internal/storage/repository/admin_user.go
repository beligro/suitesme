package repository

import (
	"suitesme/internal/models"

	"gorm.io/gorm"
)

type AdminUserRepository struct {
	db *gorm.DB
}

func NewAdminUserRepository(db *gorm.DB) *AdminUserRepository {
	return &AdminUserRepository{db: db}
}

func (repo *AdminUserRepository) Get(username string, password string) (*models.DbAdminUser, error) {
	adminUser := &models.DbAdminUser{Username: username, Password: password}

	result := repo.db.First(adminUser)

	return adminUser, result.Error
}
