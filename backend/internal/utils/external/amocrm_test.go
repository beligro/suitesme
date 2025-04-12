package external

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"suitesme/internal/config"
	"suitesme/internal/models"
	"suitesme/pkg/logging"

	"github.com/sirupsen/logrus"
	"github.com/stretchr/testify/assert"
)

// Store original values to restore after tests
var (
	originalClient  = httpClient
	originalBaseURL = amoCRMBaseURL
)

// Mock HTTP server for testing
func setupMockServer(t *testing.T, statusCode int, response string) *httptest.Server {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check for Authorization header
		authHeader := r.Header.Get("Authorization")
		if !strings.HasPrefix(authHeader, "Bearer ") {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		w.WriteHeader(statusCode)
		w.Write([]byte(response))
	}))

	// Set the global client and base URL to use our mock server
	httpClient = server.Client()
	amoCRMBaseURL = server.URL

	return server
}

// Helper function to restore original values after tests
func restoreOriginalValues() {
	httpClient = originalClient
	amoCRMBaseURL = originalBaseURL
}

// Create a mock logger for testing
func createMockLogger() *logging.Logger {
	l := logrus.New()
	l.SetOutput(logrus.StandardLogger().Out)
	entry := logrus.NewEntry(l)
	return &logging.Logger{Entry: entry}
}

func TestFindContact_Success(t *testing.T) {
	// Setup mock server
	mockResponse := `{
		"_embedded": {
			"contacts": [
				{
					"id": 12345,
					"name": "Test User"
				}
			]
		}
	}`
	server := setupMockServer(t, http.StatusOK, mockResponse)
	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Execute
	contactId, err := findContact(cfg, "test@example.com")

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, contactId)
	assert.Equal(t, 12345, *contactId)
}

func TestFindContact_NoContent(t *testing.T) {
	// Setup mock server
	server := setupMockServer(t, http.StatusNoContent, "")
	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Execute
	contactId, err := findContact(cfg, "test@example.com")

	// Assert
	assert.NoError(t, err)
	assert.Nil(t, contactId)
}

func TestFindContact_Error(t *testing.T) {
	// Setup mock server
	server := setupMockServer(t, http.StatusInternalServerError, "")
	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Execute
	contactId, err := findContact(cfg, "test@example.com")

	// Assert
	assert.Error(t, err)
	assert.Nil(t, contactId)
}

func TestCreateComplexLead_Success(t *testing.T) {
	// Setup mock server
	mockResponse := `[
		{
			"id": 54321,
			"contact_id": 12345,
			"company_id": 67890
		}
	]`
	server := setupMockServer(t, http.StatusOK, mockResponse)
	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Create test user
	user := &models.DbUser{
		FirstName: "John",
		LastName:  "Doe",
		Email:     "john.doe@example.com",
	}

	// Execute with contact ID
	contactId := 12345
	leadId, err := createComplexLead(cfg, user, &contactId)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, leadId)
	assert.Equal(t, 54321, *leadId)
}

func TestCreateComplexLead_WithoutContactId(t *testing.T) {
	// Setup mock server
	mockResponse := `[
		{
			"id": 54321,
			"contact_id": 12345,
			"company_id": 67890
		}
	]`
	server := setupMockServer(t, http.StatusOK, mockResponse)
	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Create test user
	user := &models.DbUser{
		FirstName: "John",
		LastName:  "Doe",
		Email:     "john.doe@example.com",
	}

	// Execute without contact ID
	leadId, err := createComplexLead(cfg, user, nil)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, leadId)
	assert.Equal(t, 54321, *leadId)
}

func TestCreateComplexLead_Error(t *testing.T) {
	// Setup mock server
	server := setupMockServer(t, http.StatusInternalServerError, "")
	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Create test user
	user := &models.DbUser{
		FirstName: "John",
		LastName:  "Doe",
		Email:     "john.doe@example.com",
	}

	// Execute
	leadId, err := createComplexLead(cfg, user, nil)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, leadId)
}

func TestCreateLead_Success(t *testing.T) {
	// This test is more of an integration test that combines findContact and createComplexLead
	// In a real test, we would mock these functions, but for simplicity, we'll just verify
	// that the function calls the right methods and returns the expected result

	// Setup mock server for both findContact and createComplexLead
	mockContactResponse := `{
		"_embedded": {
			"contacts": [
				{
					"id": 12345,
					"name": "Test User"
				}
			]
		}
	}`

	// After the first request (findContact), change the response for the second request (createComplexLead)
	var requestCount = 0
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check for Authorization header
		authHeader := r.Header.Get("Authorization")
		if !strings.HasPrefix(authHeader, "Bearer ") {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		requestCount++
		if requestCount == 1 {
			// First request (findContact)
			w.WriteHeader(http.StatusOK)
			w.Write([]byte(mockContactResponse))
		} else {
			// Second request (createComplexLead)
			mockLeadResponse := `[
				{
					"id": 54321,
					"contact_id": 12345,
					"company_id": 67890
				}
			]`
			w.WriteHeader(http.StatusOK)
			w.Write([]byte(mockLeadResponse))
		}
	}))

	// Set the global client and base URL to use our mock server
	httpClient = server.Client()
	amoCRMBaseURL = server.URL

	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Create test user
	user := &models.DbUser{
		FirstName: "John",
		LastName:  "Doe",
		Email:     "john.doe@example.com",
	}

	// Create logger
	logger := createMockLogger()

	// Execute
	leadId, err := CreateLead(cfg, logger, user)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, leadId)
	assert.Equal(t, 54321, *leadId)
}

func TestUpdateLeadStatus_Success(t *testing.T) {
	// Setup mock server
	server := setupMockServer(t, http.StatusOK, "")
	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Create logger
	logger := createMockLogger()

	// Execute
	err := UpdateLeadStatus(cfg, logger, 54321, Paid, nil)

	// Assert
	assert.NoError(t, err)
}

func TestUpdateLeadStatus_WithStyle(t *testing.T) {
	// Setup mock server
	server := setupMockServer(t, http.StatusOK, "")
	defer func() {
		server.Close()
		restoreOriginalValues()
	}()

	// Create config with mock server URL
	cfg := &config.Config{
		AmocrmAccessToken: "test_token",
	}

	// Create logger
	logger := createMockLogger()

	// Execute
	style := "classic"
	err := UpdateLeadStatus(cfg, logger, 54321, GotStyle, &style)

	// Assert
	assert.NoError(t, err)
}
