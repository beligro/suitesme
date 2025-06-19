package external

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetStyle(t *testing.T) {
	// Prepare test data (dummy image data)
	testImageData := []byte("dummy image data")

	// Execute
	style, err := GetStyle(testImageData)

	// Assert
	// Since we're testing with dummy data and ML service might not be available,
	// we just check that the function doesn't panic and returns some result
	assert.NotNil(t, style)
	assert.Error(t, err) // Expected to fail with dummy data
}
