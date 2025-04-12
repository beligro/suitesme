package security

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"golang.org/x/crypto/bcrypt"
)

func TestHashPassword_Success(t *testing.T) {
	// Setup
	password := "test_password"

	// Execute
	hashedPassword, err := HashPassword(password)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, hashedPassword)
	assert.NotEqual(t, password, string(hashedPassword))

	// Verify that the hash can be compared with the original password
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	assert.NoError(t, err)
}

func TestHashPassword_EmptyPassword(t *testing.T) {
	// Setup
	password := ""

	// Execute
	hashedPassword, err := HashPassword(password)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, hashedPassword)

	// Verify that the hash can be compared with the empty password
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	assert.NoError(t, err)
}

func TestComparePasswordWithHash_Success(t *testing.T) {
	// Setup
	password := "test_password"
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

	// Execute
	err := ComparePasswordWithHash(password, string(hashedPassword))

	// Assert
	assert.NoError(t, err)
}

func TestComparePasswordWithHash_WrongPassword(t *testing.T) {
	// Setup
	password := "test_password"
	wrongPassword := "wrong_password"
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

	// Execute
	err := ComparePasswordWithHash(wrongPassword, string(hashedPassword))

	// Assert
	assert.Error(t, err)
}

func TestComparePasswordWithHash_InvalidHash(t *testing.T) {
	// Setup
	password := "test_password"
	invalidHash := "invalid_hash"

	// Execute
	err := ComparePasswordWithHash(password, invalidHash)

	// Assert
	assert.Error(t, err)
}
