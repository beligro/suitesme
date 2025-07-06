package models

import (
	"time"

	"github.com/google/uuid"
)

type DbUserStyle struct {
	ID        uuid.UUID `pg:"id,pk" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserId    uuid.UUID `pg:"user_id" gorm:"type:uuid;not null;index"`
	PhotoUrl  string    `pg:"photo_url" gorm:"type:varchar(128);not null"`
	StyleId   string    `pg:"style_id" gorm:"type:varchar(64);not null"`
	CreatedAt time.Time `pg:"created_at" gorm:"autoCreateTime;not null"`
	UpdatedAt time.Time `pg:"updated_at" gorm:"autoUpdateTime;not null"`

	UserAuthInfo DbUser `gorm:"foreignKey:user_id;references:id;constraint:OnDelete:CASCADE;"`
}
