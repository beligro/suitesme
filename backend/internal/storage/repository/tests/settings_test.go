package tests

import (
	"errors"
	"testing"

	"suitesme/internal/models"
	"suitesme/internal/storage/repository"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func setupSettingsTest(t *testing.T) (*repository.SettingsRepository, sqlmock.Sqlmock, *gorm.DB) {
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

	repo := repository.NewSettingsRepository(db)
	return repo, mock, db
}

func TestSettingsRepository_List(t *testing.T) {
	// Setup
	repo, mock, _ := setupSettingsTest(t)
	sort := "id"
	order := "asc"
	limit := 10
	offset := 0

	rows := sqlmock.NewRows([]string{"id", "key", "value"}).
		AddRow(1, "setting1", "value1").
		AddRow(2, "setting2", "value2")

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	settings := repo.List(sort, order, limit, offset)

	// Assert
	assert.Len(t, settings, 2)
	assert.Equal(t, 1, settings[0].ID)
	assert.Equal(t, "setting1", settings[0].Key)
	assert.Equal(t, "value1", settings[0].Value)
	assert.Equal(t, 2, settings[1].ID)
	assert.Equal(t, "setting2", settings[1].Key)
	assert.Equal(t, "value2", settings[1].Value)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestSettingsRepository_ListAll(t *testing.T) {
	// Setup
	repo, mock, _ := setupSettingsTest(t)

	rows := sqlmock.NewRows([]string{"id", "key", "value"}).
		AddRow(1, "setting1", "value1").
		AddRow(2, "setting2", "value2").
		AddRow(3, "setting3", "value3")

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	settings := repo.ListAll()

	// Assert
	assert.Len(t, settings, 3)
	assert.Equal(t, 1, settings[0].ID)
	assert.Equal(t, "setting1", settings[0].Key)
	assert.Equal(t, "value1", settings[0].Value)
	assert.Equal(t, 3, settings[2].ID)
	assert.Equal(t, "setting3", settings[2].Key)
	assert.Equal(t, "value3", settings[2].Value)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestSettingsRepository_Get_Success(t *testing.T) {
	// Setup
	repo, mock, _ := setupSettingsTest(t)
	id := 1

	rows := sqlmock.NewRows([]string{"id", "key", "value"}).
		AddRow(id, "setting1", "value1")

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	setting, err := repo.Get(id)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, setting)
	assert.Equal(t, id, setting.ID)
	assert.Equal(t, "setting1", setting.Key)
	assert.Equal(t, "value1", setting.Value)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestSettingsRepository_Get_NotFound(t *testing.T) {
	// Setup
	repo, mock, _ := setupSettingsTest(t)
	id := 999

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnError(errors.New("record not found"))

	// Execute
	setting, err := repo.Get(id)

	// Assert
	assert.Error(t, err)
	assert.Equal(t, "record not found", err.Error())
	assert.NotNil(t, setting) // GORM initializes the struct with the provided values
	assert.Equal(t, id, setting.ID)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestSettingsRepository_Count(t *testing.T) {
	// Setup
	repo, mock, _ := setupSettingsTest(t)
	expectedCount := int64(5)

	rows := sqlmock.NewRows([]string{"count"}).AddRow(expectedCount)
	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).WillReturnRows(rows)

	// Execute
	count := repo.Count()

	// Assert
	assert.Equal(t, expectedCount, count)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestSettingsRepository_Create(t *testing.T) {
	// Setup
	repo, mock, _ := setupSettingsTest(t)
	setting := &models.DbSettings{
		Key:   "new_setting",
		Value: "new_value",
	}

	mock.ExpectBegin()
	// Using simplified SQL query expectation
	mock.ExpectQuery(`INSERT(.*)`).
		WillReturnRows(sqlmock.NewRows([]string{"id"}).AddRow(1))
	mock.ExpectCommit()

	// Execute
	repo.Create(setting)

	// Assert
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestSettingsRepository_Save(t *testing.T) {
	// Setup
	repo, mock, _ := setupSettingsTest(t)
	setting := &models.DbSettings{
		ID:    1,
		Key:   "updated_setting",
		Value: "updated_value",
	}

	mock.ExpectBegin()
	// Using simplified SQL query expectation
	mock.ExpectExec(`UPDATE(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute
	repo.Save(setting)

	// Assert
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestSettingsRepository_Delete(t *testing.T) {
	// Setup
	repo, mock, _ := setupSettingsTest(t)
	setting := &models.DbSettings{
		ID: 1,
	}

	mock.ExpectBegin()
	// Using simplified SQL query expectation
	mock.ExpectExec(`DELETE(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute
	repo.Delete(setting)

	// Assert
	assert.NoError(t, mock.ExpectationsWereMet())
}
