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
	Image string `json:"image"`
}

type MLResponse struct {
	PredictedClass string  `json:"predicted_class"`
	Confidence     float64 `json:"confidence"`
}

func GetStyle(photoData []byte) (string, error) {
	// Encode photo to base64
	base64Image := base64.StdEncoding.EncodeToString(photoData)

	// Prepare request
	mlRequest := MLRequest{
		Image: base64Image,
	}

	requestBody, err := json.Marshal(mlRequest)
	if err != nil {
		return "", fmt.Errorf("failed to marshal request: %w", err)
	}

	// Send request to ML service
	resp, err := http.Post("http://ml:8000/predict/simple", "application/json", bytes.NewBuffer(requestBody))
	if err != nil {
		return "", fmt.Errorf("failed to send request to ML service: %w", err)
	}
	defer resp.Body.Close()

	// Process 400 from ML service - indicates no face detected in the photo
	if resp.StatusCode == http.StatusBadRequest {
		return "", fmt.Errorf("no face detected in the photo")
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("ML service returned status %d", resp.StatusCode)
	}

	// Read response
	responseBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response: %w", err)
	}

	// Parse response
	var mlResponse MLResponse
	if err := json.Unmarshal(responseBody, &mlResponse); err != nil {
		return "", fmt.Errorf("failed to unmarshal response: %w", err)
	}

	return mlResponse.PredictedClass, nil
}
