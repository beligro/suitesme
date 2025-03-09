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
	MinioRootUser          string
	MinioRootPassword      string
	MinioEndpoint          string
	MinioFilePathEndpoint  string
	MinioRegion            string
	StylePhotoBucket       string
	AmocrmAccessToken      string
	ProdamusToken          string
}

func New(logger *logging.Logger) *Config {
	return &Config{
		LogLevel:               getEnv("LOG_LEVEL", "", logger),
		DbHost:                 getEnv("DB_HOST", "", logger),
		DbPort:                 getEnv("DB_PORT", "", logger),
		DbName:                 getEnv("DB_NAME", "", logger),
		DbUser:                 getEnv("DB_USER", "", logger),
		DbPassword:             getEnv("DB_PASSWORD", "", logger),
		HTTPAddr:               getEnv("HTTP_ADDR", "", logger),
		AccessTokenExpMinutes:  getEnvInt64("ACCESS_TOKEN_EXP_MINUTES", 0, logger),
		RefreshTokenExpMinutes: getEnvInt64("REFRESH_TOKEN_EXP_MINUTES", 0, logger),
		AccessTokenSecret:      getEnvBytes("ACCESS_TOKEN_SECRET", "", logger),
		RefreshTokenSecret:     getEnvBytes("REFRESH_TOKEN_SECRET", "", logger),
		EmailSendFrom:          getEnv("EMAIL_SEND_FROM", "", logger),
		EmailPassword:          getEnv("EMAIL_PASSWORD", "", logger),
		SmtpHost:               getEnv("SMTP_HOST", "", logger),
		SmtpPort:               getEnv("SMTP_PORT", "", logger),
		MinioRootUser:          getEnv("MINIO_ROOT_USER", "", logger),
		MinioRootPassword:      getEnv("MINIO_ROOT_PASSWORD", "", logger),
		MinioEndpoint:          getEnv("MINIO_ENDPOINT", "", logger),
		MinioFilePathEndpoint:  getEnv("MINIO_FILE_PATH_ENDPOINT", "", logger),
		MinioRegion:            getEnv("MINIO_REGION", "", logger),
		StylePhotoBucket:       getEnv("STYLE_PHOTO_BUCKET", "", logger),
		AmocrmAccessToken:      getEnv("AMOCRM_ACCESS_TOKEN", "", logger),
		ProdamusToken:          getEnv("PRODAMUS_TOKEN", "", logger),
	}
}

func getEnv(key string, defaultVal string, logger *logging.Logger) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}

	logger.Error("Not found key = " + key)
	return defaultVal
}

func getEnvBytes(key string, defaultVal string, logger *logging.Logger) []byte {
	if value, exists := os.LookupEnv(key); exists {
		return []byte(value)
	}

	logger.Error("Not found key = " + key)
	return []byte(defaultVal)
}

func getEnvInt64(key string, defaultVal int64, logger *logging.Logger) int64 {
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
