package app

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"suitesme/internal/utils/helper"
	"suitesme/internal/utils/security"
	"suitesme/pkg/logging"
	"time"

	"github.com/golang-jwt/jwt/v4"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/sirupsen/logrus"
)

func JWTOptionalAuthMiddleware(secret []byte) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			authHeader := c.Request().Header.Get("Authorization")
			if authHeader == "" {
				return next(c)
			}

			tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
			claims, err := security.ParseToken(tokenStr, secret)
			if err != nil {
				return echo.NewHTTPError(http.StatusUnauthorized, "Invalid token")
			}

			c.Set("userID", claims.UserId)
			return next(c)
		}
	}
}

func JWTAuthMiddleware(secret []byte) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			authHeader := c.Request().Header.Get("Authorization")
			if authHeader == "" {
				return echo.NewHTTPError(http.StatusUnauthorized, "Missing authorization header")
			}

			tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
			claims, err := security.ParseToken(tokenStr, secret)
			if err != nil {
				return echo.NewHTTPError(http.StatusUnauthorized, "Invalid token")
			}

			c.Set("userID", claims.UserId)
			return next(c)
		}
	}
}

func ParseUserID(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		userID := c.Get("userID").(uuid.UUID)
		c.Set("userID", userID)
		return next(c)
	}
}

func AdminJWTAuthMiddleware(secret []byte) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			authHeader := c.Request().Header.Get("Authorization")
			if authHeader == "" {
				return echo.NewHTTPError(http.StatusUnauthorized, "Missing authorization header")
			}

			tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
			token, err := jwt.ParseWithClaims(tokenStr, &security.AdminTokenClaims{}, func(token *jwt.Token) (interface{}, error) {
				if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, echo.NewHTTPError(http.StatusUnauthorized, "Invalid signing method")
				}
				return secret, nil
			})
			if err != nil {
				return echo.NewHTTPError(http.StatusUnauthorized, "Invalid token")
			}

			if claims, ok := token.Claims.(*security.AdminTokenClaims); ok && token.Valid {
				c.Set("adminUsername", claims.Username)
			} else {
				return echo.NewHTTPError(http.StatusUnauthorized, "Invalid token claims")
			}

			return next(c)
		}
	}
}

type bodyDumpResponseWriter struct {
	http.ResponseWriter
	body *bytes.Buffer
}

func (w *bodyDumpResponseWriter) Write(b []byte) (int, error) {
	w.body.Write(b) // записываем в промежуточный буфер
	return w.ResponseWriter.Write(b)
}

func LoggerMiddleware(logger *logging.Logger) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			traceId := c.Get("trace_id")

			req := c.Request()
			reqBodyBytes, err := io.ReadAll(req.Body)
			if err != nil {
				return err
			}
			req.Body = io.NopCloser(bytes.NewBuffer(reqBodyBytes))
			var reqBody interface{}
			if err := json.Unmarshal(reqBodyBytes, &reqBody); err != nil {
				reqBody = string(reqBodyBytes)
			}

			url := req.URL.String()

			bodyStr := helper.StructToString(reqBody)

			logger.WithFields(logrus.Fields{
				"method":   req.Method,
				"url":      url,
				"body":     bodyStr[:min(len(bodyStr), 4096)],
				"trace_id": traceId,
			}).Info("Start handling")

			resBodyBuffer := new(bytes.Buffer)
			writer := &bodyDumpResponseWriter{
				ResponseWriter: c.Response().Writer,
				body:           resBodyBuffer,
			}
			c.Response().Writer = writer

			start := time.Now()
			err = next(c)
			duration := time.Since(start) / 1000000

			if err != nil {
				c.Error(err)
			}

			var resBody interface{}
			if err := json.Unmarshal(writer.body.Bytes(), &resBody); err != nil {
				resBody = writer.body.String()
			}
			resFields := logrus.Fields{
				"status":      c.Response().Status,
				"url":         url,
				"duration_ms": duration,
				"body":        helper.StructToString(resBody),
				"trace_id":    traceId,
			}

			switch {
			case c.Response().Status >= 400 && c.Response().Status < 500:
				logger.WithFields(resFields).Warn("Finish handling")
			case c.Response().Status >= 500:
				logger.WithFields(resFields).Error("Finish handling")
			default:
				logger.WithFields(resFields).Info("Finish handling")
			}

			return err
		}
	}
}

func TraceIdMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		traceId := uuid.New().String()

		c.Set("trace_id", traceId)
		c.Response().Header().Set("X-Trace-Id", traceId)

		return next(c)
	}
}
