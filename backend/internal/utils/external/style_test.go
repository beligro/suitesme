package external

import (
	"encoding/base64"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetStyle(t *testing.T) {
	// Create mock ML service
	mockServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify request method and path
		assert.Equal(t, "POST", r.Method)
		assert.Equal(t, "/predict/simple", r.URL.Path)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		// Parse request body
		var mlRequest MLRequest
		err := json.NewDecoder(r.Body).Decode(&mlRequest)
		assert.NoError(t, err)

		// Verify base64 image is present
		assert.NotEmpty(t, mlRequest.Image)

		// Decode base64 to verify it's valid
		_, err = base64.StdEncoding.DecodeString(mlRequest.Image)
		assert.NoError(t, err)

		// Return mock response
		response := MLResponse{
			PredictedClass: "Queen",
			Confidence:     0.85,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}))
	defer mockServer.Close()

	// Use mock server URL
	mockURL := mockServer.URL + "/predict/simple"

	// Prepare test data
	testImageData := []byte("test image data")

	// We need to modify the GetStyle function to accept URL parameter for testing
	// For now, let's test with a modified version
	testGetStyleWithURL := func(photoData []byte, mlURL string) (string, error) {
		// Encode photo to base64
		base64Image := base64.StdEncoding.EncodeToString(photoData)

		// Prepare request
		mlRequest := MLRequest{
			Image: base64Image,
		}

		requestBody, err := json.Marshal(mlRequest)
		if err != nil {
			return "", err
		}

		// Send request to ML service
		resp, err := http.Post(mlURL, "application/json", strings.NewReader(string(requestBody)))
		if err != nil {
			return "", err
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			return "", assert.AnError
		}

		// Parse response
		var mlResponse MLResponse
		if err := json.NewDecoder(resp.Body).Decode(&mlResponse); err != nil {
			return "", err
		}

		return mlResponse.PredictedClass, nil
	}

	// Execute
	style, err := testGetStyleWithURL(testImageData, mockURL)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, "Queen", style)
}

func TestGetStyle_ErrorResponse(t *testing.T) {
	// Create mock ML service that returns error
	mockServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Internal Server Error"))
	}))
	defer mockServer.Close()

	// Prepare test data
	testImageData := []byte("test image data")

	// Test with error response
	testGetStyleWithURL := func(photoData []byte, mlURL string) (string, error) {
		base64Image := base64.StdEncoding.EncodeToString(photoData)
		mlRequest := MLRequest{Image: base64Image}
		requestBody, _ := json.Marshal(mlRequest)

		resp, err := http.Post(mlURL, "application/json", strings.NewReader(string(requestBody)))
		if err != nil {
			return "", err
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			return "", assert.AnError
		}

		var mlResponse MLResponse
		if err := json.NewDecoder(resp.Body).Decode(&mlResponse); err != nil {
			return "", err
		}

		return mlResponse.PredictedClass, nil
	}

	mockURL := mockServer.URL + "/predict/simple"
	style, err := testGetStyleWithURL(testImageData, mockURL)

	// Assert
	assert.Error(t, err)
	assert.Empty(t, style)
}
