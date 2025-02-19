package base64

import (
	"encoding/base64"
	"encoding/json"
)

func Encode(m map[string]interface{}) (*string, error) {
	jsonBytes, err := json.Marshal(m)
	if err != nil {
		return nil, err
	}

	base64Str := base64.StdEncoding.EncodeToString(jsonBytes)
	return &base64Str, nil
}
