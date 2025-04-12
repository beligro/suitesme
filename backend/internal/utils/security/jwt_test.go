package security

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v4"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

func TestTokenClaims_Valid(t *testing.T) {
	// Setup
	claims := TokenClaims{
		UserId: uuid.New(),
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour)),
		},
	}

	// Execute
	err := claims.Valid()

	// Assert
	assert.NoError(t, err)
}

func TestGenerateToken(t *testing.T) {
	// Setup
	userID := uuid.New()
	expireTimeDuration := time.Hour
	tokenSecret := []byte("test_secret")

	// Execute
	token, err := GenerateToken(userID, expireTimeDuration, tokenSecret)

	// Assert
	assert.NoError(t, err)
	assert.NotEmpty(t, token)

	// Verify the token
	parsedToken, err := jwt.ParseWithClaims(token, &TokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		return tokenSecret, nil
	})

	assert.NoError(t, err)
	assert.True(t, parsedToken.Valid)

	// Check claims
	if claims, ok := parsedToken.Claims.(*TokenClaims); ok {
		assert.Equal(t, userID, claims.UserId)
		assert.NotNil(t, claims.IssuedAt)
		assert.NotNil(t, claims.ExpiresAt)

		// Check that the expiration time is correct
		expectedExpTime := claims.IssuedAt.Time.Add(expireTimeDuration)
		assert.Equal(t, expectedExpTime.Unix(), claims.ExpiresAt.Time.Unix())
	} else {
		t.Fail()
	}
}

func TestParseToken_Success(t *testing.T) {
	// Setup
	userID := uuid.New()
	expireTimeDuration := time.Hour
	tokenSecret := []byte("test_secret")

	// Generate a token
	token, err := GenerateToken(userID, expireTimeDuration, tokenSecret)
	assert.NoError(t, err)

	// Execute
	claims, err := ParseToken(token, tokenSecret)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, claims)
	assert.Equal(t, userID, claims.UserId)
}

func TestParseToken_InvalidToken(t *testing.T) {
	// Setup
	tokenSecret := []byte("test_secret")
	invalidToken := "invalid.token.string"

	// Execute
	claims, err := ParseToken(invalidToken, tokenSecret)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, claims)
}

func TestParseToken_WrongSecret(t *testing.T) {
	// Setup
	userID := uuid.New()
	expireTimeDuration := time.Hour
	tokenSecret := []byte("test_secret")
	wrongSecret := []byte("wrong_secret")

	// Generate a token
	token, err := GenerateToken(userID, expireTimeDuration, tokenSecret)
	assert.NoError(t, err)

	// Execute
	claims, err := ParseToken(token, wrongSecret)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, claims)
}

// Note: We're not testing GenerateTokens here because it requires mocking
// the storage and echo.Context, which would be more complex and prone to errors.
// In a real-world scenario, you would use a mocking framework like gomock or testify/mock
// to create proper mocks for these dependencies.
