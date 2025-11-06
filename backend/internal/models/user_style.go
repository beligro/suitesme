package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
)

type DbUserStyle struct {
	ID                 uuid.UUID      `pg:"id,pk" gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	UserId             uuid.UUID      `pg:"user_id" gorm:"type:uuid;not null;index" json:"userId"`
	PhotoUrl           string         `pg:"photo_url" gorm:"type:varchar(128);not null" json:"photoUrl"`
	PhotoUrls          datatypes.JSON `pg:"photo_urls" gorm:"type:jsonb" json:"photoUrls"`
	StyleId            string         `pg:"style_id" gorm:"type:varchar(64);not null" json:"styleId"`
	InitialPrediction  string         `pg:"initial_prediction" gorm:"type:varchar(64)" json:"initialPrediction"`
	Confidence         float64        `pg:"confidence" gorm:"type:float8;default:0" json:"confidence"`
	IsVerified         bool           `pg:"is_verified" gorm:"not null;default:false" json:"isVerified"`
	VerifiedBy         *int           `pg:"verified_by" gorm:"type:int" json:"verifiedBy"`
	VerifiedAt         *time.Time     `pg:"verified_at" json:"verifiedAt"`
	CreatedAt          time.Time      `pg:"created_at" gorm:"autoCreateTime;not null" json:"createdAt"`
	UpdatedAt          time.Time      `pg:"updated_at" gorm:"autoUpdateTime;not null" json:"updatedAt"`

	UserAuthInfo    DbUser      `gorm:"foreignKey:user_id;references:id;constraint:OnDelete:CASCADE;" json:"-"`
	VerifiedByAdmin DbAdminUser `gorm:"foreignKey:verified_by;references:id;" json:"-"`
}

type PredictionStatistics struct {
	TotalPredictions       int64                      `json:"totalPredictions"`
	VerifiedCount          int64                      `json:"verifiedCount"`
	UnverifiedCount        int64                      `json:"unverifiedCount"`
	AccuracyRate           float64                    `json:"accuracyRate"`
	ConfusionMatrix        map[string]map[string]int  `json:"confusionMatrix"`
	PerClassAccuracy       map[string]float64         `json:"perClassAccuracy"`
	ConfidenceDistribution ConfidenceDistribution     `json:"confidenceDistribution"`
}

type ConfidenceDistribution struct {
	Low    int `json:"low"`    // 0-0.33
	Medium int `json:"medium"` // 0.34-0.66
	High   int `json:"high"`   // 0.67-1.0
}
