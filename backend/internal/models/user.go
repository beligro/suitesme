package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type DbUser struct {
	gorm.Model
	ID                 uuid.UUID `pg:"id,pk" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	Email              string    `pg:"email" gorm:"type:varchar(128);uniqueIndex:idx_email;not null"`
	PasswordHash       string    `pg:"password_hash" gorm:"type:varchar(128);not null"`
	FirstName          string    `pg:"first_name" gorm:"type:varchar(128);not null"`
	LastName           string    `pg:"last_name" gorm:"type:varchar(128);not null"`
	BirthDate          string    `pg:"birth_date" gorm:"type:varchar(10);not null"`
	VerificationCode   string    `pg:"verification_code"`
	IsVerified         bool      `pg:"is_verified" gorm:"not null;default:false"`
	IsAdmin            bool      `pg:"is_admin" gorm:"not null;default:false"`
	PasswordResetToken string    `pg:"password_reset_token"`
	PasswordResetAt    time.Time `pg:"password_reset_at"`
	AmocrmLeadId       int       `pg:"amocrm_lead_id"`
}

type MutableUserFields struct {
	FirstName *string `json:"first_name"`
	LastName  *string `json:"last_name"`
	BirthDate *string `json:"birth_date"`
}
