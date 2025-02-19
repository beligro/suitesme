package helper

import (
	"encoding/json"
)

func StructToString(s interface{}) string {
	jsonData, err := json.MarshalIndent(s, "", "  ")
	if err != nil {
		return ""
	}

	return string(jsonData)
}
