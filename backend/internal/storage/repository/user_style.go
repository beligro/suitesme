package repository

import (
	"suitesme/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserStyleRepository struct {
	db *gorm.DB
}

func NewUserStyleRepository(db *gorm.DB) *UserStyleRepository {
	return &UserStyleRepository{db: db}
}

func (repo *UserStyleRepository) Get(userId uuid.UUID) (string, error) {
	var userStyle models.DbUserStyle

	// Order by created_at desc to get the latest style
	result := repo.db.Where("user_id = ?", userId).Order("created_at desc").First(&userStyle)

	return userStyle.StyleId, result.Error
}

func (repo *UserStyleRepository) GetById(id uuid.UUID) (*models.DbUserStyle, error) {
	var userStyle models.DbUserStyle
	err := repo.db.Where("id = ?", id).First(&userStyle).Error
	if err != nil {
		return nil, err
	}
	return &userStyle, nil
}

func (repository *UserStyleRepository) Create(userStyle *models.DbUserStyle) {
	repository.db.Create(&userStyle)
}

type PredictionListParams struct {
	Limit      int
	Offset     int
	IsVerified *bool
	SortBy     string
	SortOrder  string
}

func (repo *UserStyleRepository) List(params PredictionListParams) ([]models.DbUserStyle, int64, error) {
	var styles []models.DbUserStyle
	var total int64

	query := repo.db.Model(&models.DbUserStyle{})

	// Apply filters
	if params.IsVerified != nil {
		query = query.Where("is_verified = ?", *params.IsVerified)
	}

	// Get total count
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Apply sorting
	sortBy := "created_at"
	if params.SortBy != "" {
		sortBy = params.SortBy
	}
	sortOrder := "DESC"
	if params.SortOrder != "" {
		sortOrder = params.SortOrder
	}
	query = query.Order(sortBy + " " + sortOrder)

	// Apply pagination
	if params.Limit > 0 {
		query = query.Limit(params.Limit)
	}
	if params.Offset > 0 {
		query = query.Offset(params.Offset)
	}

	err := query.Find(&styles).Error
	return styles, total, err
}

func (repo *UserStyleRepository) Verify(id uuid.UUID, verifiedPrediction string, verifiedBy int) error {
	now := gorm.Expr("NOW()")
	return repo.db.Model(&models.DbUserStyle{}).
		Where("id = ?", id).
		Updates(map[string]interface{}{
			"style_id":    verifiedPrediction,
			"is_verified": true,
			"verified_by": verifiedBy,
			"verified_at": now,
		}).Error
}

func (repo *UserStyleRepository) GetStatistics() (*models.PredictionStatistics, error) {
	var stats models.PredictionStatistics

	// Get total predictions
	if err := repo.db.Model(&models.DbUserStyle{}).Count(&stats.TotalPredictions).Error; err != nil {
		return nil, err
	}

	// Get verified count
	if err := repo.db.Model(&models.DbUserStyle{}).Where("is_verified = ?", true).Count(&stats.VerifiedCount).Error; err != nil {
		return nil, err
	}

	stats.UnverifiedCount = stats.TotalPredictions - stats.VerifiedCount

	// Calculate accuracy (predictions that were not changed)
	var unchangedCount int64
	if err := repo.db.Model(&models.DbUserStyle{}).
		Where("is_verified = ? AND initial_prediction = style_id", true).
		Count(&unchangedCount).Error; err != nil {
		return nil, err
	}

	if stats.VerifiedCount > 0 {
		stats.AccuracyRate = float64(unchangedCount) / float64(stats.VerifiedCount) * 100
	}

	// Build confusion matrix
	stats.ConfusionMatrix = make(map[string]map[string]int)
	var verifiedStyles []models.DbUserStyle
	if err := repo.db.Where("is_verified = ?", true).Find(&verifiedStyles).Error; err != nil {
		return nil, err
	}

	for _, style := range verifiedStyles {
		if stats.ConfusionMatrix[style.InitialPrediction] == nil {
			stats.ConfusionMatrix[style.InitialPrediction] = make(map[string]int)
		}
		stats.ConfusionMatrix[style.InitialPrediction][style.StyleId]++
	}

	// Calculate per-class accuracy
	stats.PerClassAccuracy = make(map[string]float64)
	for initialClass, verifiedClasses := range stats.ConfusionMatrix {
		correctCount := verifiedClasses[initialClass]
		totalCount := 0
		for _, count := range verifiedClasses {
			totalCount += count
		}
		if totalCount > 0 {
			stats.PerClassAccuracy[initialClass] = float64(correctCount) / float64(totalCount) * 100
		}
	}

	// Calculate confidence distribution
	var allStyles []models.DbUserStyle
	if err := repo.db.Find(&allStyles).Error; err != nil {
		return nil, err
	}

	for _, style := range allStyles {
		if style.Confidence <= 0.33 {
			stats.ConfidenceDistribution.Low++
		} else if style.Confidence <= 0.66 {
			stats.ConfidenceDistribution.Medium++
		} else {
			stats.ConfidenceDistribution.High++
		}
	}

	return &stats, nil
}

func (repo *UserStyleRepository) Delete(id uuid.UUID) error {
	result := repo.db.Where("id = ?", id).Delete(&models.DbUserStyle{})
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return result.Error
}
