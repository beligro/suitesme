package security

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

func TestGetResetToken(t *testing.T) {
	// Execute
	token := GetResetToken()

	// Assert
	assert.NotEmpty(t, token)
	assert.Len(t, token, 20) // The token should be 20 characters long
}

func TestGetResetToken_Uniqueness(t *testing.T) {
	// Generate multiple tokens and check they're different
	tokens := make([]string, 10)
	for i := 0; i < 10; i++ {
		tokens[i] = GetResetToken()
	}

	// Check that at least some tokens are different
	uniqueTokens := make(map[string]bool)
	for _, token := range tokens {
		uniqueTokens[token] = true
	}

	// Assert that we have more than 1 unique token
	assert.Greater(t, len(uniqueTokens), 1)
}

func TestEncode_Decode(t *testing.T) {
	// Setup
	userId := uuid.New()
	resetToken := GetResetToken()
	resetTokenInfo := &ResetTokenStruct{
		UserId:     userId,
		ResetToken: resetToken,
	}

	// Execute
	encoded, err := Encode(resetTokenInfo)
	assert.NoError(t, err)
	assert.NotEmpty(t, encoded)

	// Decode the encoded token
	decoded, err := Decode(encoded)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, decoded)
	assert.Equal(t, userId, decoded.UserId)
	assert.Equal(t, resetToken, decoded.ResetToken)
}

func TestDecode_InvalidBase64(t *testing.T) {
	// Setup
	invalidBase64 := "invalid base64 string"

	// Execute
	decoded, err := Decode(invalidBase64)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, decoded)
}

func TestDecode_InvalidJSON(t *testing.T) {
	// Setup
	// Valid base64 but invalid JSON
	invalidJSON := "eyJpbnZhbGlkIjoianNvbn0="

	// Execute
	decoded, err := Decode(invalidJSON)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, decoded)
}
