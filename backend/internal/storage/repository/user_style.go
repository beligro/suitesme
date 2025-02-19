package repository

import (
	"gorm.io/gorm"
)

type UserStyleRepository struct {
	db *gorm.DB
}

func NewUserStyleRepository(db *gorm.DB) *UserStyleRepository {
	return &UserStyleRepository{db: db}
}
