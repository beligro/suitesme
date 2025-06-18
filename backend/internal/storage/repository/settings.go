package repository

import (
	"suitesme/internal/models"

	"gorm.io/gorm"
)

type SettingsRepository struct {
	db *gorm.DB
}

func NewSettingsRepository(db *gorm.DB) *SettingsRepository {
	return &SettingsRepository{db: db}
}

func (repo *SettingsRepository) List(sort string, order string, limit int, offset int) []models.DbSettings {
	settings := []models.DbSettings{}

	repo.db.Order(sort + " " + order).Limit(limit).Offset(offset).Find(&settings)

	return settings
}

func (repo *SettingsRepository) ListAll() []models.DbSettings {
	settings := []models.DbSettings{}

	repo.db.Find(&settings)

	return settings
}

func (repo *SettingsRepository) Get(id int) (*models.DbSettings, error) {
	setting := &models.DbSettings{}

	result := repo.db.Model(&models.DbSettings{}).Where("id = ?", id).First(setting)

	return setting, result.Error
}

func (repo *SettingsRepository) Count() int64 {
	var total int64
	repo.db.Model(&models.DbSettings{}).Count(&total)

	return total
}

func (repo *SettingsRepository) Create(setting *models.DbSettings) {
	repo.db.Create(setting)
}

func (repo *SettingsRepository) Save(setting *models.DbSettings) {
	repo.db.Save(setting)
}

func (repo *SettingsRepository) Delete(setting *models.DbSettings) {
	repo.db.Delete(setting)
}
