package tests

import (
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

func setupPaymentsTest(t *testing.T) (*repository.PaymentsRepository, sqlmock.Sqlmock, *gorm.DB) {
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

	repo := repository.NewPaymentsRepository(db)
	return repo, mock, db
}

func TestPaymentsRepository_Get_Success(t *testing.T) {
	// Setup
	repo, mock, _ := setupPaymentsTest(t)
	userId := uuid.New()
	status := models.Paid
	paymentLink := "https://payment.example.com/123"
	paymentSum := "100.00"
	createdAt := time.Now()
	updatedAt := time.Now()

	rows := sqlmock.NewRows([]string{"user_id", "status", "payment_link", "payment_sum", "created_at", "updated_at"}).
		AddRow(userId, status, paymentLink, paymentSum, createdAt, updatedAt)

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Execute
	payment := repo.Get(userId)

	// Assert
	assert.NotNil(t, payment)
	assert.Equal(t, userId, payment.UserId)
	assert.Equal(t, status, payment.Status)
	assert.Equal(t, paymentLink, payment.PaymentLink)
	assert.Equal(t, paymentSum, payment.PaymentSum)
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestPaymentsRepository_Get_NotFound(t *testing.T) {
	// Setup
	repo, mock, _ := setupPaymentsTest(t)
	userId := uuid.New()

	// Using simplified SQL query expectation
	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(sqlmock.NewRows([]string{"user_id", "status", "payment_link", "payment_sum", "created_at", "updated_at"}))

	// Execute
	payment := repo.Get(userId)

	// Assert
	assert.NotNil(t, payment) // GORM initializes the struct with the provided values
	assert.Equal(t, userId, payment.UserId)
	assert.Equal(t, models.PaymentStatus(""), payment.Status) // Default value for PaymentStatus
	assert.Equal(t, "", payment.PaymentLink)                  // Default value for string
	assert.Equal(t, "", payment.PaymentSum)                   // Default value for string
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestPaymentsRepository_Create(t *testing.T) {
	// Setup
	repo, mock, _ := setupPaymentsTest(t)
	userId := uuid.New()
	status := models.CreatedLink
	paymentLink := "https://payment.example.com/123"
	paymentSum := "100.00"

	payment := &models.DbPayments{
		UserId:      userId,
		Status:      status,
		PaymentLink: paymentLink,
		PaymentSum:  paymentSum,
	}

	// Expect the INSERT operation
	mock.ExpectBegin()
	mock.ExpectExec(`INSERT(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute the Create operation
	repo.Create(payment)

	// Now verify that the data was correctly stored by mocking a SELECT query
	// This simulates checking the database after the insert
	createdAt := time.Now() // Mock a creation time
	updatedAt := time.Now() // Mock an update time

	rows := sqlmock.NewRows([]string{"user_id", "status", "payment_link", "payment_sum", "created_at", "updated_at"}).
		AddRow(userId, status, paymentLink, paymentSum, createdAt, updatedAt)

	mock.ExpectQuery(`SELECT(.*)`).
		WillReturnRows(rows)

	// Retrieve the payment we just created
	retrievedPayment := repo.Get(userId)

	// Assert that the retrieved payment matches what we inserted
	assert.NotNil(t, retrievedPayment)
	assert.Equal(t, userId, retrievedPayment.UserId)
	assert.Equal(t, status, retrievedPayment.Status)
	assert.Equal(t, paymentLink, retrievedPayment.PaymentLink)
	assert.Equal(t, paymentSum, retrievedPayment.PaymentSum)

	// Verify all expectations were met
	assert.NoError(t, mock.ExpectationsWereMet())
}

func TestPaymentsRepository_Save(t *testing.T) {
	// Setup
	repo, mock, _ := setupPaymentsTest(t)
	userId := uuid.New()
	payment := &models.DbPayments{
		UserId:      userId,
		Status:      models.Paid,
		PaymentLink: "https://payment.example.com/123",
		PaymentSum:  "100.00",
	}

	mock.ExpectBegin()
	// Using simplified SQL query expectation
	mock.ExpectExec(`UPDATE(.*)`).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	// Execute
	repo.Save(payment)

	// Assert
	assert.NoError(t, mock.ExpectationsWereMet())
}
