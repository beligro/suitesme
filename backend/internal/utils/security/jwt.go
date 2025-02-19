package security

import (
	"fmt"
	"net/http"
	"suitesme/internal/config"
	"suitesme/internal/models"
	"suitesme/internal/storage"
	"suitesme/pkg/myerrors"
	"time"

	"github.com/golang-jwt/jwt/v4"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type TokenClaims struct {
	UserId uuid.UUID
	jwt.RegisteredClaims
}

func (c TokenClaims) Valid() error {
	return nil
}

func GenerateTokens(userID uuid.UUID, cfg *config.Config, storage *storage.Storage) (*models.TokensResponse, *echo.HTTPError) {
	accessExpDuration := time.Minute * time.Duration(cfg.AccessTokenExpMinutes)
	refreshExpDuration := time.Minute * time.Duration(cfg.RefreshTokenExpMinutes)

	accessToken, err := GenerateToken(userID, accessExpDuration, cfg.AccessTokenSecret)
	if err != nil {
		return nil, myerrors.GetHttpErrorByCode(http.StatusForbidden)
	}

	refreshToken, err := GenerateToken(userID, refreshExpDuration, cfg.RefreshTokenSecret)
	if err != nil {
		return nil, myerrors.GetHttpErrorByCode(http.StatusForbidden)
	}

	dbToken := models.DbTokens{
		UserId:       userID,
		RefreshToken: refreshToken,
		CreatedAt:    time.Now(),
		ExpiredAt:    time.Now().Add(refreshExpDuration),
		IsRemoved:    false,
	}

	err = storage.Tokens.CreateToken(&dbToken)
	if err != nil {
		return nil, myerrors.GetHttpErrorByCode(http.StatusInternalServerError)
	}

	response := models.TokensResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}

	return &response, nil
}

func GenerateToken(userID uuid.UUID, expireTimeDuration time.Duration, tokenSecret []byte) (string, error) {
	claims := TokenClaims{
		UserId: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(expireTimeDuration)),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString(tokenSecret)
}

func ParseToken(refreshToken string, secret []byte) (*TokenClaims, error) {
	token, err := jwt.ParseWithClaims(refreshToken, &TokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}

		return secret, nil
	})
	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(*TokenClaims)
	if !ok {
		return nil, fmt.Errorf("invalid token claims")
	}

	return claims, nil
}
