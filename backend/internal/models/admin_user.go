package models

type DbAdminUser struct {
	ID       int    `pg:"id,pk" gorm:"type:serial;primaryKey" json:"id"`
	Username string `pg:"username" gorm:"type:varchar(128);uniqueIndex:idx_username;not null"`
	Password string `pg:"password" gorm:"not null"`
}
