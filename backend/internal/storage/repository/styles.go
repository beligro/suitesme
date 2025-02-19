package repository

import (
	"gorm.io/gorm"
)

type StylesRepository struct {
	db *gorm.DB
}

func NewStylesRepository(db *gorm.DB) *StylesRepository {
	return &StylesRepository{db: db}
}
