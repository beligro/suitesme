package repository

import (
	"suitesme/internal/models"

	"gorm.io/gorm"
)

type WebContentRepository struct {
	db *gorm.DB
}

func NewWebContentRepository(db *gorm.DB) *WebContentRepository {
	return &WebContentRepository{db: db}
}

func (repo *WebContentRepository) List(sort string, order string, limit int, offset int) []models.DbWebContent {
	contents := []models.DbWebContent{}

	repo.db.Order(sort + " " + order).Limit(limit).Offset(offset).Find(&contents)

	return contents
}

func (repo *WebContentRepository) ListAll() []models.DbWebContent {
	contents := []models.DbWebContent{}

	repo.db.Find(&contents)

	return contents
}

func (repo *WebContentRepository) Get(id int) (*models.DbWebContent, error) {
	content := &models.DbWebContent{}

	result := repo.db.Model(&models.DbWebContent{}).Where("id = ?", id).First(content)

	return content, result.Error
}

func (repo *WebContentRepository) Count() int64 {
	var total int64
	repo.db.Model(&models.DbWebContent{}).Count(&total)

	return total
}

func (repo *WebContentRepository) Create(content *models.DbWebContent) {
	repo.db.Create(content)
}

func (repo *WebContentRepository) Save(content *models.DbWebContent) {
	repo.db.Save(content)
}

func (repo *WebContentRepository) Delete(content *models.DbWebContent) {
	repo.db.Delete(content)
}
