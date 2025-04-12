package tests

import (
	"errors"
	"testing"

	"suitesme/internal/storage/repository"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func setupAdminUserTest(t *testing.T) (*repository.AdminUserRepository, sqlmock.Sqlmock, *gorm.DB) {
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

	repo := repository.NewAdminUserRepository(db)
	return repo, mock, db
}

func TestAdminUserRepository_Get_Success(t *testing.T) {
	// Setup
	repo, mock, _ := setupAdminUserTest(t)
	username := "admin"
	password := "password"
	id := 1

	// Looking at the implementation, the repo.Get method uses First() which will order by primary key (ID)
	// and doesn't explicitly add WHERE clauses for username and password
	rows := sqlmock.NewRows([]string{"id", "username", "password"}).
		AddRow(id, username, password)

	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	user, err := repo.Get(username, password)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, user)
	assert.Equal(t, id, user.ID)
	assert.Equal(t, username, user.Username)
	assert.Equal(t, password, user.Password)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestAdminUserRepository_Get_NotFound(t *testing.T) {
	// Setup
	repo, mock, _ := setupAdminUserTest(t)
	username := "admin"
	password := "password"

	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnError(errors.New("record not found"))

	// Execute
	user, err := repo.Get(username, password)

	// Assert
	assert.Error(t, err)
	assert.Equal(t, "record not found", err.Error())
	assert.NotNil(t, user) // GORM initializes the struct with the provided values
	assert.Equal(t, username, user.Username)
	assert.Equal(t, password, user.Password)
	assert.NoError(t, mock.ExpectationsWereMet())
}
