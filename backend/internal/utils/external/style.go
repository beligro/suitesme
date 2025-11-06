package external

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type MLRequest struct {
	Images []string `json:"images"`
}

type MLResponse struct {
	PredictedClass string  `json:"predicted_class"`
	Confidence     float64 `json:"confidence"`
}

func GetStyle(photosData [][]byte) (string, float64, error) {
	// Validate that we have 1-4 photos
	if len(photosData) < 1 || len(photosData) > 4 {
		return "", 0, fmt.Errorf("must provide 1-4 photos, got %d", len(photosData))
	}

	// Encode all photos to base64
	base64Images := make([]string, len(photosData))
	for i, photoData := range photosData {
		base64Images[i] = base64.StdEncoding.EncodeToString(photoData)
	}

	// Prepare request
	mlRequest := MLRequest{
		Images: base64Images,
	}

	requestBody, err := json.Marshal(mlRequest)
	if err != nil {
		return "", 0, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Send request to ML service
	resp, err := http.Post("http://ml:8000/predict/simple", "application/json", bytes.NewBuffer(requestBody))
	if err != nil {
		return "", 0, fmt.Errorf("failed to send request to ML service: %w", err)
	}
	defer resp.Body.Close()

	// Process 400 from ML service - indicates no face detected in the photo
	if resp.StatusCode == http.StatusBadRequest {
		return "", 0, fmt.Errorf("no face detected in the photo")
	}

	if resp.StatusCode != http.StatusOK {
		return "", 0, fmt.Errorf("ML service returned status %d", resp.StatusCode)
	}

	// Read response
	responseBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", 0, fmt.Errorf("failed to read response: %w", err)
	}

	// Parse response
	var mlResponse MLResponse
	if err := json.Unmarshal(responseBody, &mlResponse); err != nil {
		return "", 0, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	return mlResponse.PredictedClass, mlResponse.Confidence, nil
}
