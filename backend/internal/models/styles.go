package models

type DbStyle struct {
	Id         string `pg:"id,pk" gorm:"type:varchar(64);primaryKey"`
	Name       string `pg:"name" gorm:"type:varchar(128);not null"`
	Comment    string `pg:"comment" gorm:"type:text;not null"`
	PdfInfoUrl string `pg:"pdf_info_url" gorm:"type:varchar(256);not null"`
}
