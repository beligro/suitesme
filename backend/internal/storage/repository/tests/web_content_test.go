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

func setupWebContentTest(t *testing.T) (*repository.WebContentRepository, sqlmock.Sqlmock, *gorm.DB) {
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

	repo := repository.NewWebContentRepository(db)
	return repo, mock, db
}

func TestWebContentRepository_List(t *testing.T) {
	// Setup
	repo, mock, _ := setupWebContentTest(t)
	sort := "id"
	order := "asc"
	limit := 10
	offset := 0

	rows := sqlmock.NewRows([]string{"id", "key", "ru_value", "en_value"}).
		AddRow(1, "content1", "ru_value1", "en_value1").
		AddRow(2, "content2", "ru_value2", "en_value2")

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	contents := repo.List(sort, order, limit, offset)

	// Assert
	assert.Len(t, contents, 2)
	assert.Equal(t, 1, contents[0].ID)
	assert.Equal(t, "content1", contents[0].Key)
	assert.Equal(t, "ru_value1", contents[0].RuValue)
	assert.Equal(t, "en_value1", contents[0].EnValue)
	assert.Equal(t, 2, contents[1].ID)
	assert.Equal(t, "content2", contents[1].Key)
	assert.Equal(t, "ru_value2", contents[1].RuValue)
	assert.Equal(t, "en_value2", contents[1].EnValue)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestWebContentRepository_ListAll(t *testing.T) {
	// Setup
	repo, mock, _ := setupWebContentTest(t)

	rows := sqlmock.NewRows([]string{"id", "key", "ru_value", "en_value"}).
		AddRow(1, "content1", "ru_value1", "en_value1").
		AddRow(2, "content2", "ru_value2", "en_value2").
		AddRow(3, "content3", "ru_value3", "en_value3")

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	contents := repo.ListAll()

	// Assert
	assert.Len(t, contents, 3)
	assert.Equal(t, 1, contents[0].ID)
	assert.Equal(t, "content1", contents[0].Key)
	assert.Equal(t, "ru_value1", contents[0].RuValue)
	assert.Equal(t, "en_value1", contents[0].EnValue)
	assert.Equal(t, 3, contents[2].ID)
	assert.Equal(t, "content3", contents[2].Key)
	assert.Equal(t, "ru_value3", contents[2].RuValue)
	assert.Equal(t, "en_value3", contents[2].EnValue)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestWebContentRepository_Get_Success(t *testing.T) {
	// Setup
	repo, mock, _ := setupWebContentTest(t)
	id := 1

	rows := sqlmock.NewRows([]string{"id", "key", "ru_value", "en_value"}).
		AddRow(id, "content1", "ru_value1", "en_value1")

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	content, err := repo.Get(id)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, content)
	assert.Equal(t, id, content.ID)
	assert.Equal(t, "content1", content.Key)
	assert.Equal(t, "ru_value1", content.RuValue)
	assert.Equal(t, "en_value1", content.EnValue)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestWebContentRepository_Get_NotFound(t *testing.T) {
	// Setup
	repo, mock, _ := setupWebContentTest(t)
	id := 999

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnError(errors.New("record not found"))

	// Execute
	content, err := repo.Get(id)

	// Assert
	assert.Error(t, err)
	assert.Equal(t, "record not found", err.Error())
	assert.NotNil(t, content) // GORM initializes the struct with the provided values
	assert.Equal(t, id, content.ID)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestWebContentRepository_Count(t *testing.T) {
	// Setup
	repo, mock, _ := setupWebContentTest(t)
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

func TestWebContentRepository_Create(t *testing.T) {
	// Setup
	repo, mock, _ := setupWebContentTest(t)
	content := &models.DbWebContent{
		Key:     "new_content",
		RuValue: "new_ru_value",
		EnValue: "new_en_value",
	}

	mock.ExpectBegin()
	// Using simplified SQL query expectation
	mock.ExpectQuery(`INSERT(.*)`).
		WillReturnRows(sqlmock.NewRows([]string{"id"}).AddRow(1))
	mock.ExpectCommit()

	// Execute
	repo.Create(content)

	// Assert
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestWebContentRepository_Save(t *testing.T) {
	// Setup
	repo, mock, _ := setupWebContentTest(t)
	content := &models.DbWebContent{
		ID:      1,
		Key:     "updated_content",
		RuValue: "updated_ru_value",
		EnValue: "updated_en_value",
	}

	mock.ExpectBegin()
	// Using simplified SQL query expectation
	mock.ExpectExec(`UPDATE(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute
	repo.Save(content)

	// Assert
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestWebContentRepository_Delete(t *testing.T) {
	// Setup
	repo, mock, _ := setupWebContentTest(t)
	content := &models.DbWebContent{
		ID: 1,
	}

	mock.ExpectBegin()
	// Using simplified SQL query expectation
	mock.ExpectExec(`DELETE(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute
	repo.Delete(content)

	// Assert
	assert.NoError(t, mock.ExpectationsWereMet())
}
