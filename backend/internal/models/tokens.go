package models

import (
	"time"

	"github.com/google/uuid"
)

type DbTokens struct {
	UserId       uuid.UUID `pg:"user_id" gorm:"type:uuid;primaryKey"`
	RefreshToken string    `pg:"refresh_token" gorm:"type:varchar(256);primaryKey"`
	CreatedAt    time.Time `pg:"created_at" gorm:"autoCreateTime;not null"`
	ExpiredAt    time.Time `pg:"expired_at" gorm:"not null"`
	IsRemoved    bool      `pg:"is_removed" gorm:"not null;default:false"`

	UserAuthInfo DbUser `gorm:"foreignKey:user_id;references:id;constraint:OnDelete:CASCADE;"`
}

type TokensResponse struct {
	AccessToken  string `json:"access_token" validate:"required"`
	RefreshToken string `json:"refresh_token" validate:"required"`
}
