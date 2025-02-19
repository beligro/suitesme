package config

import (
	"os"
	"strconv"
	"suitesme/pkg/logging"
)

type Config struct {
	LogLevel               string
	DbHost                 string
	DbPort                 string
	DbName                 string
	DbUser                 string
	DbPassword             string
	HTTPAddr               string
	AccessTokenExpMinutes  int64
	RefreshTokenExpMinutes int64
	AccessTokenSecret      []byte
	RefreshTokenSecret     []byte
	EmailSendFrom          string
	EmailPassword          string
	SmtpHost               string
	SmtpPort               string
}

func New() *Config {
	return &Config{
		LogLevel:               getEnv("LOG_LEVEL", ""),
		DbHost:                 getEnv("DB_HOST", ""),
		DbPort:                 getEnv("DB_PORT", ""),
		DbName:                 getEnv("DB_NAME", ""),
		DbUser:                 getEnv("DB_USER", ""),
		DbPassword:             getEnv("DB_PASSWORD", ""),
		HTTPAddr:               getEnv("HTTP_ADDR", ""),
		AccessTokenExpMinutes:  getEnvInt64("ACCESS_TOKEN_EXP_MINUTES", 0),
		RefreshTokenExpMinutes: getEnvInt64("REFRESH_TOKEN_EXP_MINUTES", 0),
		AccessTokenSecret:      getEnvBytes("ACCESS_TOKEN_SECRET", ""),
		RefreshTokenSecret:     getEnvBytes("REFRESH_TOKEN_SECRET", ""),
		EmailSendFrom:          getEnv("EMAIL_SEND_FROM", ""),
		EmailPassword:          getEnv("EMAIL_PASSWORD", ""),
		SmtpHost:               getEnv("SMTP_HOST", ""),
		SmtpPort:               getEnv("SMTP_PORT", ""),
	}
}

func getEnv(key string, defaultVal string) string {
	logger := logging.GetLogger()

	if value, exists := os.LookupEnv(key); exists {
		return value
	}

	logger.Error("Not found key = " + key)
	return defaultVal
}

func getEnvBytes(key string, defaultVal string) []byte {
	logger := logging.GetLogger()

	if value, exists := os.LookupEnv(key); exists {
		return []byte(value)
	}

	logger.Error("Not found key = " + key)
	return []byte(defaultVal)
}

func getEnvInt64(key string, defaultVal int64) int64 {
	logger := logging.GetLogger()

	if value, exists := os.LookupEnv(key); exists {
		parsedValue, err := strconv.ParseInt(value, 10, 64)
		if err != nil {
			logger.Panic("Can't parse to int " + key)
		}
		return parsedValue
	}

	logger.Error("Not found key = " + key)
	return defaultVal
}
