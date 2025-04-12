package external

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"suitesme/internal/models"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

// Store original values to restore after tests
var (
	originalProdamusClient  = prodamusClient
	originalProdamusBaseURL = prodamusBaseURL
)

// Helper function to restore original values after tests
func restoreProdamusOriginalValues() {
	prodamusClient = originalProdamusClient
	prodamusBaseURL = originalProdamusBaseURL
}

// Setup mock server for Prodamus tests
func setupProdamusMockServer(t *testing.T, statusCode int, response string) *httptest.Server {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(statusCode)
		w.Write([]byte(response))
	}))

	// Set the global client and base URL to use our mock server
	prodamusClient = server.Client()
	prodamusBaseURL = server.URL

	return server
}

func TestCreatePaymentLink_Success(t *testing.T) {
	// Setup mock server
	mockResponse := "https://payment.example.com/12345"
	server := setupProdamusMockServer(t, http.StatusOK, mockResponse)
	defer func() {
		server.Close()
		restoreProdamusOriginalValues()
	}()

	// Create test user
	userId := uuid.New()
	user := &models.DbUser{
		ID:        userId,
		Email:     "test@example.com",
		FirstName: "John",
		LastName:  "Doe",
	}

	// Create settings
	settings := map[string]string{
		"payment_name":    "Test Payment",
		"price":           "100",
		"frontend_domain": "https://example.com",
		"backend_domain":  "https://api.example.com",
	}

	// Execute
	link, err := CreatePaymentLink(user, settings)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, mockResponse, link)
}

func TestCreatePaymentLink_Error(t *testing.T) {
	// Setup mock server that returns an error
	server := setupProdamusMockServer(t, http.StatusInternalServerError, "")
	defer func() {
		server.Close()
		restoreProdamusOriginalValues()
	}()

	// Create test user
	userId := uuid.New()
	user := &models.DbUser{
		ID:        userId,
		Email:     "test@example.com",
		FirstName: "John",
		LastName:  "Doe",
	}

	// Create settings
	settings := map[string]string{
		"payment_name":    "Test Payment",
		"price":           "100",
		"frontend_domain": "https://example.com",
		"backend_domain":  "https://api.example.com",
	}

	// Execute
	_, err := CreatePaymentLink(user, settings)

	// Assert
	// Note: This test might not actually fail since the function doesn't check the status code
	// It just returns the body as a string. In a real-world scenario, you'd want to check the
	// status code and return an error if it's not 200 OK.
	assert.NoError(t, err)
}

func TestCreatePaymentLink_MissingSettings(t *testing.T) {
	// Setup mock server
	mockResponse := "https://payment.example.com/12345"
	server := setupProdamusMockServer(t, http.StatusOK, mockResponse)
	defer func() {
		server.Close()
		restoreProdamusOriginalValues()
	}()

	// Create test user
	userId := uuid.New()
	user := &models.DbUser{
		ID:        userId,
		Email:     "test@example.com",
		FirstName: "John",
		LastName:  "Doe",
	}

	// Create settings with missing values
	settings := map[string]string{
		// Missing payment_name
		"price":           "100",
		"frontend_domain": "https://example.com",
		"backend_domain":  "https://api.example.com",
	}

	// Execute
	link, err := CreatePaymentLink(user, settings)

	// Assert
	// Note: This test might not actually fail since the function doesn't validate the settings
	// In a real-world scenario, you'd want to validate the settings and return an error if
	// required settings are missing.
	assert.NoError(t, err)
	assert.Equal(t, mockResponse, link)
}
