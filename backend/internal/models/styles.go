package models

type DbStyle struct {
	Id         string `pg:"id,pk" gorm:"type:varchar(64);primaryKey" json:"id"`
	Name       string `pg:"name" gorm:"type:varchar(128);uniqueIndex:idx_name;not null" json:"name"`
	Comment    string `pg:"comment" gorm:"type:text;not null" json:"comment"`
	PdfInfoUrl string `pg:"pdf_info_url" gorm:"type:varchar(256);not null" json:"pdfInfoUrl"`
}
