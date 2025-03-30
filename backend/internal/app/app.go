package app

import (
	"fmt"
	"log"
	"net/http"
	"suitesme/internal/config"
	"suitesme/internal/handlers/api/v1/auth"
	"suitesme/internal/handlers/api/v1/payment"
	"suitesme/internal/handlers/api/v1/profile"
	"suitesme/internal/handlers/api/v1/style"
	"suitesme/internal/storage"
	"suitesme/pkg/logging"
	"suitesme/pkg/myerrors"
	"suitesme/pkg/validator"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
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

	cfg := config.New(&logger)
	logger.Info("config initialized")

	dbParams := fmt.Sprintf("host=%s dbname=%s user=%s password=%s sslmode=disable", cfg.DbHost, cfg.DbName, cfg.DbUser, cfg.DbPassword)
	storage, err := storage.NewDB(dbParams)
	if err != nil {
		logger.Panic(err)
	}

	sess, err := session.NewSession(&aws.Config{
		Region:           aws.String(cfg.MinioRegion),
		Credentials:      credentials.NewStaticCredentials(cfg.MinioRootUser, cfg.MinioRootPassword, ""),
		Endpoint:         aws.String(cfg.MinioEndpoint),
		S3ForcePathStyle: aws.Bool(true),
	})
	if err != nil {
		log.Fatal(err)
	}
	s3Client := s3.New(sess)

	authController := auth.NewAuthController(&logger, storage, cfg)
	paymentController := payment.NewPaymentController(&logger, storage, cfg)
	profileController := profile.NewProfileController(&logger, storage)
	styleController := style.NewStyleController(&logger, storage, cfg, s3Client)

	e := echo.New()
	e.Validator = validator.NewValidator()
	e.HTTPErrorHandler = myerrors.Error

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(TraceIdMiddleware)
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://localhost:3000", "http://51.250.84.195:3000"},
		AllowMethods: []string{echo.GET, echo.POST, echo.PUT, echo.DELETE},
		AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization},
	}))

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
	apiV1Auth.POST("/forgot_password", authController.ForgotPassword)
	apiV1Auth.POST("/password/reset", authController.PasswordReset)

	apiV1Payment := apiV1.Group("/payment")

	apiV1Payment.GET("/link", paymentController.PaymentLink, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)
	apiV1Payment.POST("/callback", paymentController.PaymentCallback)

	apiV1Profile := apiV1.Group("/profile")

	apiV1Profile.POST("/edit", profileController.Edit, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)
	apiV1Profile.GET("/info", profileController.Info, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)

	apiV1Style := apiV1.Group("/style")

	apiV1Style.POST("/build", styleController.Build, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)
	apiV1Style.GET("/info", styleController.Info, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)

	s := &http.Server{
		Addr:         cfg.HTTPAddr,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
	}
	e.Logger.Fatal(e.StartServer(s))
}
