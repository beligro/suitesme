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
	Create(*models.DbUser) uuid.UUID
	Save(*models.DbUser)
	Update(uuid.UUID, *models.MutableUserFields) error
	SetUserIsVerified(uuid.UUID, int)
}

type StylesRepository interface{}

type UserStyleRepository interface {
	Get(uuid.UUID) (string, error)
	Create(*models.DbUserStyle)
}

type TokensRepository interface {
	CreateToken(*models.DbTokens) error
	DeleteTokens(uuid.UUID) error
	GetByUserId(uuid.UUID) (*models.DbTokens, error)
	GetByPK(uuid.UUID, string) (*models.DbTokens, error)
}

type PaymentsRepository interface {
	Get(uuid.UUID) (*models.DbPayments, error)
	Create(*models.DbPayments)
	Save(*models.DbPayments)
}

type WebContentRepository interface {
	List(sort string, order string, limit int, offset int) []models.DbWebContent
	ListAll() []models.DbWebContent
	Get(int) (*models.DbWebContent, error)
	Count() int64
	Create(*models.DbWebContent)
	Save(*models.DbWebContent)
	Delete(*models.DbWebContent)
}

type SettingsRepository interface {
	List(sort string, order string, limit int, offset int) []models.DbSettings
	ListAll() []models.DbSettings
	Get(int) (*models.DbSettings, error)
	Count() int64
	Create(*models.DbSettings)
	Save(*models.DbSettings)
	Delete(*models.DbSettings)
}

type AdminUserRepository interface {
	Get(string, string) (*models.DbAdminUser, error)
}
