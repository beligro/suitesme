package repository

import (
	"suitesme/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (repo *UserRepository) CheckVerifiedUserExists(email string) bool {
	var result models.DbUser

	pgRes := repo.db.
		Where("email = ? AND is_verified", email).
		Limit(1).
		Find(&result)

	return pgRes.RowsAffected > 0
}

func (repo *UserRepository) Get(id uuid.UUID) (*models.DbUser, error) {
	user := &models.DbUser{ID: id}

	result := repo.db.First(user)

	return user, result.Error
}

func (repo *UserRepository) GetForPasswordReset(id uuid.UUID, passwordResetToken string) (*models.DbUser, error) {
	var user models.DbUser
	result := repo.db.First(&user, "id = ? AND password_reset_token = ? AND password_reset_at > NOW()", id, passwordResetToken)
	if result.Error != nil {
		return nil, result.Error
	}

	return &user, nil
}

func (repo *UserRepository) GetByEmail(email string) (*models.DbUser, error) {
	user := &models.DbUser{Email: email}

	result := repo.db.First(user)

	return user, result.Error
}

func (repo *UserRepository) Create(user *models.DbUser) (uuid.UUID, error) {
	err := repo.db.Clauses(clause.OnConflict{
		Columns: []clause.Column{{Name: "email"}},
		DoUpdates: clause.Assignments(map[string]interface{}{
			"verification_code": user.VerificationCode,
			"password_hash":     user.PasswordHash,
			"first_name":        user.FirstName,
			"last_name":         user.LastName,
			"birth_date":        user.BirthDate,
		}),
	}).Create(user).Error

	return user.ID, err
}

func (repo *UserRepository) Save(user *models.DbUser) {
	repo.db.Save(user)
}

func (repo *UserRepository) Update(userId uuid.UUID, fields *models.MutableUserFields) error {
	if fields == nil {
		return nil
	}

	userUpdates := make(map[string]interface{})

	if fields.FirstName != nil {
		userUpdates["first_name"] = *fields.FirstName
	}
	if fields.LastName != nil {
		userUpdates["last_name"] = *fields.LastName
	}
	if fields.BirthDate != nil {
		userUpdates["birth_date"] = *fields.BirthDate
	}

	if len(userUpdates) == 0 {
		return nil
	}

	return repo.db.Model(&models.DbUser{}).Where("id = ?", userId).Updates(userUpdates).Error
}

func (repo *UserRepository) SetUserIsVerified(userId uuid.UUID, leadId int) error {
	return repo.db.Model(&models.DbUser{}).Where("id = ?", userId).Updates(map[string]interface{}{"is_verified": true, "verification_code": nil, "amocrm_lead_id": leadId}).Error
}
