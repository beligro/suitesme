package tests

import (
	"errors"
	"testing"

	"suitesme/internal/models"
	"suitesme/internal/storage/repository"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func setupUserStyleTest(t *testing.T) (*repository.UserStyleRepository, sqlmock.Sqlmock, *gorm.DB) {
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

	repo := repository.NewUserStyleRepository(db)
	return repo, mock, db
}

func TestUserStyleRepository_Get_Success(t *testing.T) {
	// Setup
	repo, mock, _ := setupUserStyleTest(t)
	userId := uuid.New()
	styleId := "style123"

	rows := sqlmock.NewRows([]string{"user_id", "style_id"}).
		AddRow(userId, styleId)

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	result, err := repo.Get(userId)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, styleId, result)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestUserStyleRepository_Get_NotFound(t *testing.T) {
	// Setup
	repo, mock, _ := setupUserStyleTest(t)
	userId := uuid.New()

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnError(errors.New("record not found"))

	// Execute
	result, err := repo.Get(userId)

	// Assert
	assert.Error(t, err)
	assert.Equal(t, "record not found", err.Error())
	assert.Equal(t, "", result) // Default value for string
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestUserStyleRepository_Create(t *testing.T) {
	// Setup
	repo, mock, _ := setupUserStyleTest(t)
	userId := uuid.New()
	styleId := "style123"

	userStyle := &models.DbUserStyle{
		UserId:  userId,
		StyleId: styleId,
	}

	// Expect the INSERT operation
	mock.ExpectBegin()
	mock.ExpectExec(`INSERT(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute the Create operation
	repo.Create(userStyle)

	// Now verify that the data was correctly stored by mocking a SELECT query
	// This simulates checking the database after the insert
	rows := sqlmock.NewRows([]string{"user_id", "style_id"}).
		AddRow(userId, styleId)

	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Retrieve the user style we just created
	retrievedStyleId, err := repo.Get(userId)

	// Assert that the retrieved style matches what we inserted
	assert.NoError(t, err)
	assert.Equal(t, styleId, retrievedStyleId)

	// Verify all expectations were met
	assert.NoError(t, mock.ExpectationsWereMet())
}
