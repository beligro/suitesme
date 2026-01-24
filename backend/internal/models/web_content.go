package models

type DbWebContent struct {
	ID      int    `pg:"id,pk" gorm:"type:integer;primaryKey;autoIncrement" json:"id"`
	Key     string `pg:"key" gorm:"type:varchar(128);uniqueIndex:idx_key;not null" json:"key"`
	RuValue string `pg:"ru_value" gorm:"not null" json:"ru_value"`
	EnValue string `pg:"en_value" gorm:"not null" json:"en_value"`
}

type UpsertContentRequest struct {
	Key     string `json:"key" validate:"required"`
	RuValue string `json:"ru_value" validate:"required"`
	EnValue string `json:"en_value" validate:"required"`
}

type WebContentCacheItem struct {
	RuValue string `json:"ru_value" validate:"required"`
	EnValue string `json:"en_value" validate:"required"`
}
