package security

import (
	"time"

	"github.com/golang-jwt/jwt/v4"
)

type AdminTokenClaims struct {
	Username string
	jwt.RegisteredClaims
}

func (c AdminTokenClaims) Valid() error {
	return nil
}

func GenerateAdminToken(username string, tokenSecret []byte) (string, error) {
	claims := AdminTokenClaims{
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * 72)),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString(tokenSecret)
}
