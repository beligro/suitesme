package models

import (
	"time"

	"github.com/google/uuid"
)

type DbUserStyle struct {
	UserId    uuid.UUID `pg:"user_id,pk" gorm:"type:uuid;primaryKey"`
	PhotoUrl  string    `pg:"photo_url" gorm:"type:varchar(128);not null"`
	StyleId   string    `pg:"style_id" gorm:"type:varchar(64);not null"`
	CreatedAt time.Time `pg:"created_at" gorm:"autoCreateTime;not null"`
	UpdatedAt time.Time `pg:"updated_at" gorm:"autoUpdateTime;not null"`

	UserAuthInfo DbUser  `gorm:"foreignKey:user_id;references:id;constraint:OnDelete:CASCADE;"`
	Style        DbStyle `gorm:"foreignKey:style_id;references:id;constraint:OnDelete:CASCADE;"`
}
