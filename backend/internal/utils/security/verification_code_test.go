package security

import (
	"regexp"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetVerificationCode(t *testing.T) {
	// Execute
	code := GetVerificationCode()

	// Assert
	assert.NotEmpty(t, code)
	assert.Len(t, code, codeLength)

	// Verify that the code contains only digits
	match, err := regexp.MatchString(`^\d{6}$`, code)
	assert.NoError(t, err)
	assert.True(t, match)
}

func TestGetVerificationCode_Uniqueness(t *testing.T) {
	// Generate multiple codes and check they're different
	codes := make([]string, 10)
	for i := 0; i < 10; i++ {
		codes[i] = GetVerificationCode()
	}

	// Check that at least some codes are different
	// (There's a very small chance they could all be the same by random chance)
	uniqueCodes := make(map[string]bool)
	for _, code := range codes {
		uniqueCodes[code] = true
	}

	// Assert that we have more than 1 unique code
	assert.Greater(t, len(uniqueCodes), 1)
}

func TestGetVerificationCode_Length(t *testing.T) {
	// Execute
	code := GetVerificationCode()

	// Assert
	assert.Equal(t, codeLength, len(code))
}
