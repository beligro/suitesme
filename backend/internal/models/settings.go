package models

type DbSettings struct {
	ID    int    `pg:"id,pk" gorm:"type:integer;primaryKey;autoIncrement" json:"id"`
	Key   string `pg:"key" gorm:"type:varchar(128);uniqueIndex:idx_key;not null" json:"key"`
	Value string `pg:"value" gorm:"not null" json:"value"`
}

type UpsertSettingRequest struct {
	Key   string `json:"key" validate:"required"`
	Value string `json:"value" validate:"required"`
}
