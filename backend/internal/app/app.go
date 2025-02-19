package app

import (
	"fmt"
	"net/http"
	"suitesme/internal/config"
	"suitesme/internal/handlers/api/v1/auth"
	"suitesme/internal/handlers/api/v1/profile"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
	"suitesme/pkg/myerrors"
	"suitesme/pkg/validator"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	echoSwagger "github.com/swaggo/echo-swagger"
)

//	@title			SuitesMe Service
//	@version		1.0
//	@description	SuitesMe service API in Go using Echo framework.
//	@termsOfService	http://swagger.io/terms/

//	@contact.name	API Support
//	@contact.url	http://www.swagger.io/support
//	@contact.email	support@swagger.io

//	@license.name	Apache 2.0
//	@license.url	http://www.apache.org/licenses/LICENSE-2.0.html

// @host	localhost:8080
func Run() {
	logging.Init()
	logger := logging.GetLogger()
	logger.Info("logger initialized")

	cfg := config.New()
	logger.Info("config initialized")

	dbParams := fmt.Sprintf("host=%s dbname=%s user=%s password=%s sslmode=disable", cfg.DbHost, cfg.DbName, cfg.DbUser, cfg.DbPassword)
	storage, err := storage.NewDB(dbParams)
	if err != nil {
		logger.Panic(err)
	}

	authController := auth.NewAuthController(&logger, storage, cfg)
	profileController := profile.NewProfileController(&logger, storage)

	e := echo.New()
	e.Validator = validator.NewValidator()
	e.HTTPErrorHandler = myerrors.Error

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(TraceIdMiddleware)

	e.GET("/ping", func(c echo.Context) error {
		return c.String(http.StatusOK, "pong")
	})

	e.GET("/docs/*", echoSwagger.WrapHandler)

	apiRoutes := e.Group("/api")
	apiV1 := apiRoutes.Group("/v1")
	apiV1.Use(LoggerMiddleware(&logger))

	apiV1Auth := apiV1.Group("/auth")

	apiV1Auth.POST("/register", authController.Register)
	apiV1Auth.POST("/login", authController.Login)
	apiV1Auth.POST("/refresh", authController.Refresh)
	apiV1Auth.POST("/logout", authController.Logout)
	apiV1Auth.POST("/verify_email", authController.VerifyEmail)

	apiV1Profile := apiV1.Group("/profile")

	apiV1Profile.POST("/edit", profileController.Edit, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)
	apiV1Profile.POST("/info", profileController.Info, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)

	s := &http.Server{
		Addr:         cfg.HTTPAddr,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
	}
	e.Logger.Fatal(e.StartServer(s))
}
