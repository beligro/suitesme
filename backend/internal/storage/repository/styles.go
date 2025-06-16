package repository

import (
	"suitesme/internal/models"

	"gorm.io/gorm"
)

type StylesRepository struct {
	db *gorm.DB
}

func NewStylesRepository(db *gorm.DB) *StylesRepository {
	return &StylesRepository{db: db}
}

// Get retrieves a style by ID
func (repo *StylesRepository) Get(id string) (*models.DbStyle, error) {
	var style models.DbStyle
	result := repo.db.Where("id = ?", id).First(&style)
	return &style, result.Error
}

// List returns a list of styles with pagination, sorting and ordering
func (repo *StylesRepository) List(sort string, order string, limit int, offset int) []models.DbStyle {
	var styles []models.DbStyle
	repo.db.Order(sort + " " + order).Limit(limit).Offset(offset).Find(&styles)
	return styles
}

// Count returns the total number of styles
func (repo *StylesRepository) Count() int64 {
	var count int64
	repo.db.Model(&models.DbStyle{}).Count(&count)
	return count
}

// Create creates a new style
func (repo *StylesRepository) Create(style *models.DbStyle) error {
	result := repo.db.Create(style)
	return result.Error
}

// Update updates an existing style
func (repo *StylesRepository) Update(style *models.DbStyle) error {
	result := repo.db.Save(style)
	return result.Error
}

// Delete deletes a style by ID
func (repo *StylesRepository) Delete(id string) error {
	result := repo.db.Delete(&models.DbStyle{}, "id = ?", id)
	return result.Error
}
