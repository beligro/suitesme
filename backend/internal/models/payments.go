package models

import (
	"time"

	"github.com/google/uuid"
)

type PaymentStatus string

const (
	NotFound    PaymentStatus = "not_found"
	CreatedLink PaymentStatus = "created_link"
	InProgress  PaymentStatus = "in_progress"
	Paid        PaymentStatus = "paid"
	Failed      PaymentStatus = "failed"
)

type DbPayments struct {
	UserId          uuid.UUID     `pg:"user_id,pk" gorm:"type:uuid;primaryKey"`
	Status          PaymentStatus `pg:"status" gorm:"type:varchar(64);not null"`
	PaymentLink     string        `pg:"payment_link" gorm:"not null"`
	PaymentSum      string        `pg:"payment_sum" gorm:"not null"`
	ProdamusOrderId *string       `pg:"prodamus_order_id"`
	CreatedAt       time.Time     `pg:"created_at" gorm:"autoCreateTime;not null"`
	UpdatedAt       time.Time     `pg:"updated_at" gorm:"autoUpdateTime;not null"`

	UserAuthInfo DbUser `gorm:"foreignKey:user_id;references:id;constraint:OnDelete:CASCADE;"`
}
