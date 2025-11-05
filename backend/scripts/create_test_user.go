package main

import (
	"fmt"
	"log"
	"os"
	"suitesme/internal/models"
	"suitesme/internal/storage"
	"suitesme/internal/utils/security"

	"github.com/google/uuid"
)

func main() {
	// Get database connection string from environment or use default
	// Defaults match docker-compose.yml settings
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5433") // Docker exposes postgres on 5433
	dbUser := getEnv("DB_USER", "postgres")
	dbPassword := getEnv("DB_PASSWORD", "postgres")
	dbName := getEnv("DB_NAME", "suitesme")
	
	// If DB_PASSWORD is not set, try to read from .env file or prompt
	if dbPassword == "postgres" {
		// Check if .env file exists in parent directory
		fmt.Println("Note: Using default password 'postgres'. Set DB_PASSWORD environment variable if different.")
	}

	dbParams := fmt.Sprintf("host=%s port=%s dbname=%s user=%s password=%s sslmode=disable",
		dbHost, dbPort, dbName, dbUser, dbPassword)

	// Connect to database
	db, err := storage.NewDB(dbParams)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Test user credentials
	testEmail := "test@example.com"
	testPassword := "test!Test"
	testFirstName := "Test"
	testLastName := "User"
	testBirthDate := "1990-01-01"

	// Hash password
	passwordHash, err := security.HashPassword(testPassword)
	if err != nil {
		log.Fatalf("Failed to hash password: %v", err)
	}

	// Check if user already exists
	var existingUser models.DbUser
	result := db.DB.Where("email = ?", testEmail).First(&existingUser)

	if result.Error == nil {
		// User exists, update it
		fmt.Printf("User %s already exists, updating...\n", testEmail)
		existingUser.PasswordHash = string(passwordHash)
		existingUser.FirstName = testFirstName
		existingUser.LastName = testLastName
		existingUser.BirthDate = testBirthDate
		existingUser.IsVerified = true
		existingUser.VerificationCode = ""
		existingUser.IsAdmin = true

		if err := db.DB.Save(&existingUser).Error; err != nil {
			log.Fatalf("Failed to update user: %v", err)
		}
		fmt.Printf("✓ User updated successfully\n")
		fmt.Printf("  Email: %s\n", testEmail)
		fmt.Printf("  Password: %s\n", testPassword)
		fmt.Printf("  Verified: true\n")
		fmt.Printf("  IsAdmin: true\n")
	} else {
		// Create new user
		fmt.Printf("Creating new test user...\n")
		newUser := &models.DbUser{
			ID:               uuid.New(),
			Email:            testEmail,
			PasswordHash:     string(passwordHash),
			FirstName:        testFirstName,
			LastName:         testLastName,
			BirthDate:        testBirthDate,
			VerificationCode: "",
			IsVerified:       true,
			IsAdmin:          true,
		}

		if err := db.DB.Create(newUser).Error; err != nil {
			log.Fatalf("Failed to create user: %v", err)
		}
		fmt.Printf("✓ User created successfully\n")
		fmt.Printf("  Email: %s\n", testEmail)
		fmt.Printf("  Password: %s\n", testPassword)
		fmt.Printf("  Verified: true\n")
		fmt.Printf("  IsAdmin: true\n")
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
