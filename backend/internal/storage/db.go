package storage

import (
	"suitesme/internal/models"
	"suitesme/internal/storage/repository"
	"suitesme/pkg/logging"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

type Storage struct {
	DB        *gorm.DB
	User      *repository.UserRepository
	Styles    *repository.StylesRepository
	UserStyle *repository.UserStyleRepository
	Tokens    *repository.TokensRepository
	Payments  *repository.PaymentsRepository
}

func MakeMigrations() error {
	logger := logging.GetLogger()

	if migrationErr := DB.AutoMigrate(
		&models.DbUser{},
		&models.DbStyle{},
		&models.DbUserStyle{},
		&models.DbTokens{},
		&models.DbPayments{}); migrationErr != nil {
		logger.Errorf("DB Migration Error: %v", migrationErr)
		return migrationErr
	}

	return nil
}

func NewDB(params string) (*Storage, error) {
	var storage Storage

	var err error
	for idx := 0; idx < 5; idx++ {
		DB, err = gorm.Open(postgres.Open(params), &gorm.Config{})
		if err == nil {
			break
		}
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		return nil, err
	}

	DB.Exec("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")

	storage.DB = DB
	storage.User = repository.NewUserRepository(DB)
	storage.Styles = repository.NewStylesRepository(DB)
	storage.UserStyle = repository.NewUserStyleRepository(DB)
	storage.Tokens = repository.NewTokensRepository(DB)
	storage.Payments = repository.NewPaymentsRepository(DB)

	err = MakeMigrations()
	if err != nil {
		return nil, err
	}

	return &storage, nil
}

func GetDBInstance() *gorm.DB {
	return DB
}
