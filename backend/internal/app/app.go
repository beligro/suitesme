package app

import (
	"fmt"
	"log"
	"net/http"
	"suitesme/internal/caches"
	"suitesme/internal/config"
	admin_auth "suitesme/internal/handlers/admin/auth"
	"suitesme/internal/handlers/admin/v1/content"
	"suitesme/internal/handlers/admin/v1/settings"
	"suitesme/internal/handlers/admin/v1/styles"
	"suitesme/internal/handlers/api/v1/auth"
	api_content "suitesme/internal/handlers/api/v1/content"
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
	echojwt "github.com/labstack/echo-jwt/v4"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/patrickmn/go-cache"
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

	webContentCache := cache.New(15*time.Minute, 20*time.Minute)
	settingsCache := cache.New(15*time.Minute, 20*time.Minute)

	go func() {
		for {
			caches.UpdateWebContentCache(storage, webContentCache)
			time.Sleep(15 * time.Minute)
		}
	}()

	go func() {
		for {
			caches.UpdateSettingsCache(storage, settingsCache)
			time.Sleep(15 * time.Minute)
		}
	}()

	authController := auth.NewAuthController(&logger, storage, cfg)
	paymentController := payment.NewPaymentController(&logger, storage, cfg, settingsCache)
	profileController := profile.NewProfileController(&logger, storage)
	styleController := style.NewStyleController(&logger, storage, cfg, s3Client)
	contentController := content.NewContentController(&logger, storage, cfg)
	settingsController := settings.NewSettingsController(&logger, storage, cfg)
	stylesController := styles.NewStylesController(&logger, storage, cfg, s3Client)
	adminAuthController := admin_auth.NewAdminAuthController(&logger, storage, cfg)
	apiContentController := api_content.NewApiContentController(&logger, storage, cfg, webContentCache)

	e := echo.New()
	e.Validator = validator.NewValidator()
	e.HTTPErrorHandler = myerrors.Error

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(TraceIdMiddleware)
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://51.250.84.195:3000", "http://51.250.84.195", "http://51.250.84.195:80", "http://localhost:5173", "http://localhost", "localhost:5173"},
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
	apiV1Payment.GET("/info", paymentController.Info, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)
	apiV1Payment.POST("/notify", paymentController.PaymentNotify, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)
	apiV1Payment.POST("/callback", paymentController.PaymentCallback)

	apiV1Profile := apiV1.Group("/profile")

	apiV1Profile.POST("/edit", profileController.Edit, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)
	apiV1Profile.GET("/info", profileController.Info, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)

	apiV1Style := apiV1.Group("/style")

	apiV1Style.POST("/build", styleController.Build, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)
	apiV1Style.GET("/info", styleController.Info, JWTAuthMiddleware(cfg.AccessTokenSecret), ParseUserID)

	apiV1Content := apiV1.Group("/content")

	apiV1Content.GET("/list", apiContentController.List)

	adminRoutes := e.Group("/admin")
	adminV1 := adminRoutes.Group("/v1")
	adminV1.Use(LoggerMiddleware(&logger))
	adminV1.Use(echojwt.JWT(cfg.AdminTokenSecret))

	adminV1.GET("/content", contentController.List)
	adminV1.GET("/content/:id", contentController.Get)
	adminV1.PUT("/content/:id", contentController.Put)
	adminV1.DELETE("/content/:id", contentController.Delete)
	adminV1.POST("/content", contentController.Post)

	adminV1.GET("/settings", settingsController.List)
	adminV1.GET("/settings/:id", settingsController.Get)
	adminV1.PUT("/settings/:id", settingsController.Put)
	adminV1.DELETE("/settings/:id", settingsController.Delete)
	adminV1.POST("/settings", settingsController.Post)

	adminV1.GET("/styles", stylesController.List)
	adminV1.GET("/styles/:id", stylesController.Get)
	adminV1.PUT("/styles/:id", stylesController.Put)
	adminV1.DELETE("/styles/:id", stylesController.Delete)
	adminV1.POST("/styles", stylesController.Post)

	adminAuth := adminRoutes.Group("/auth")
	adminAuth.POST("/login", adminAuthController.Login)

	s := &http.Server{
		Addr:         cfg.HTTPAddr,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
	}
	e.Logger.Fatal(e.StartServer(s))
}
