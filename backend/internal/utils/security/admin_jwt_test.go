package security

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v4"
	"github.com/stretchr/testify/assert"
)

func TestGenerateAdminToken(t *testing.T) {
	// Setup
	username := "admin"
	tokenSecret := []byte("test_secret")

	// Execute
	token, err := GenerateAdminToken(username, tokenSecret)

	// Assert
	assert.NoError(t, err)
	assert.NotEmpty(t, token)

	// Verify the token
	parsedToken, err := jwt.ParseWithClaims(token, &AdminTokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		return tokenSecret, nil
	})

	assert.NoError(t, err)
	assert.True(t, parsedToken.Valid)

	// Check claims
	if claims, ok := parsedToken.Claims.(*AdminTokenClaims); ok {
		assert.Equal(t, username, claims.Username)
		assert.NotNil(t, claims.IssuedAt)
		assert.NotNil(t, claims.ExpiresAt)

		// Check that the expiration time is 72 hours after the issued time
		expectedExpTime := claims.IssuedAt.Time.Add(time.Hour * 72)
		assert.Equal(t, expectedExpTime.Unix(), claims.ExpiresAt.Time.Unix())
	} else {
		t.Fail()
	}
}

func TestAdminTokenClaims_Valid(t *testing.T) {
	// Setup
	claims := AdminTokenClaims{
		Username: "admin",
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * 72)),
		},
	}

	// Execute
	err := claims.Valid()

	// Assert
	assert.NoError(t, err)
}
