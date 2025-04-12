package tests

import (
	"errors"
	"testing"
	"time"

	"suitesme/internal/models"
	"suitesme/internal/storage/repository"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func setupTokensTest(t *testing.T) (*repository.TokensRepository, sqlmock.Sqlmock, *gorm.DB) {
	mockDB, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("Failed to create mock DB: %v", err)
	}

	dialector := postgres.New(postgres.Config{
		DSN:                  "sqlmock_db_0",
		DriverName:           "postgres",
		Conn:                 mockDB,
		PreferSimpleProtocol: true,
	})

	db, err := gorm.Open(dialector, &gorm.Config{})
	if err != nil {
		t.Fatalf("Failed to open gorm DB: %v", err)
	}

	repo := repository.NewTokensRepository(db)
	return repo, mock, db
}

func TestTokensRepository_CreateToken(t *testing.T) {
	// Setup
	repo, mock, _ := setupTokensTest(t)
	userId := uuid.New()
	refreshToken := "refresh_token_value"
	expiredAt := time.Now().Add(24 * time.Hour)
	isRemoved := false

	token := &models.DbTokens{
		UserId:       userId,
		RefreshToken: refreshToken,
		ExpiredAt:    expiredAt,
		IsRemoved:    isRemoved,
	}

	// Expect the INSERT operation
	mock.ExpectBegin()
	mock.ExpectExec(`INSERT(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute the CreateToken operation
	err := repo.CreateToken(token)

	// Assert the operation was successful
	assert.NoError(t, err)

	// Now verify that the data was correctly stored by mocking a SELECT query
	// This simulates checking the database after the insert
	createdAt := time.Now() // Mock a creation time

	rows := sqlmock.NewRows([]string{"user_id", "refresh_token", "created_at", "expired_at", "is_removed"}).
		AddRow(userId, refreshToken, createdAt, expiredAt, isRemoved)

	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Retrieve the token we just created
	retrievedToken, err := repo.GetByUserId(userId)

	// Assert that the retrieved token matches what we inserted
	assert.NoError(t, err)
	assert.NotNil(t, retrievedToken)
	assert.Equal(t, userId, retrievedToken.UserId)
	assert.Equal(t, refreshToken, retrievedToken.RefreshToken)
	assert.Equal(t, isRemoved, retrievedToken.IsRemoved)
	assert.Equal(t, expiredAt.Unix(), retrievedToken.ExpiredAt.Unix()) // Compare Unix timestamps to avoid precision issues

	// Verify all expectations were met
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestTokensRepository_DeleteTokens(t *testing.T) {
	// Setup
	repo, mock, _ := setupTokensTest(t)
	userId := uuid.New()

	mock.ExpectBegin()
	// Using simplified SQL query expectation
	mock.ExpectExec(`UPDATE(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute
	err := repo.DeleteTokens(userId)

	// Assert
	assert.NoError(t, err)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestTokensRepository_GetByUserId_Success(t *testing.T) {
	// Setup
	repo, mock, _ := setupTokensTest(t)
	userId := uuid.New()
	refreshToken := "refresh_token_value"
	createdAt := time.Now()
	expiredAt := time.Now().Add(24 * time.Hour)
	isRemoved := false

	rows := sqlmock.NewRows([]string{"user_id", "refresh_token", "created_at", "expired_at", "is_removed"}).
		AddRow(userId, refreshToken, createdAt, expiredAt, isRemoved)

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	token, err := repo.GetByUserId(userId)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, token)
	assert.Equal(t, userId, token.UserId)
	assert.Equal(t, refreshToken, token.RefreshToken)
	assert.Equal(t, isRemoved, token.IsRemoved)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestTokensRepository_GetByUserId_NotFound(t *testing.T) {
	// Setup
	repo, mock, _ := setupTokensTest(t)
	userId := uuid.New()

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnError(errors.New("record not found"))

	// Execute
	token, err := repo.GetByUserId(userId)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, token)
	assert.Equal(t, "record not found", err.Error())
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestTokensRepository_GetByPK_Success(t *testing.T) {
	// Setup
	repo, mock, _ := setupTokensTest(t)
	userId := uuid.New()
	refreshToken := "refresh_token_value"
	createdAt := time.Now()
	expiredAt := time.Now().Add(24 * time.Hour)
	isRemoved := false

	rows := sqlmock.NewRows([]string{"user_id", "refresh_token", "created_at", "expired_at", "is_removed"}).
		AddRow(userId, refreshToken, createdAt, expiredAt, isRemoved)

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	token, err := repo.GetByPK(userId, refreshToken)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, token)
	assert.Equal(t, userId, token.UserId)
	assert.Equal(t, refreshToken, token.RefreshToken)
	assert.Equal(t, isRemoved, token.IsRemoved)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestTokensRepository_GetByPK_NotFound(t *testing.T) {
	// Setup
	repo, mock, _ := setupTokensTest(t)
	userId := uuid.New()
	refreshToken := "refresh_token_value"

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnError(errors.New("record not found"))

	// Execute
	token, err := repo.GetByPK(userId, refreshToken)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, token)
	assert.Equal(t, "record not found", err.Error())
	assert.NoError(t, mock.ExpectationsWereMet())
}
