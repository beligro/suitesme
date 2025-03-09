package storage

import (
	"suitesme/internal/models"

	"github.com/google/uuid"
)

type UserRepository interface {
	CheckVerifiedUserExists(string) bool
	Get(uuid.UUID) (*models.DbUser, error)
	GetForPasswordReset(uuid.UUID, string) (*models.DbUser, error)
	GetByEmail(string) (*models.DbUser, error)
	Create(*models.DbUser) (uuid.UUID, error)
	Save(*models.DbUser)
	Update(uuid.UUID, *models.MutableUserFields) error
	SetUserIsVerified(uuid.UUID, int) error
}

type StylesRepository interface{}

type UserStyleRepository interface {
	Get(uuid.UUID) (string, error)
	Create(*models.DbUserStyle) error
}

type TokensRepository interface {
	CreateToken(*models.DbTokens) error
	DeleteTokens(uuid.UUID) error
	GetByUserId(uuid.UUID) (*models.DbTokens, error)
	GetByPK(uuid.UUID, string) (*models.DbTokens, error)
}
