package base64

import (
	"encoding/base64"
	"encoding/json"
)

func Decode(s string) (map[string]interface{}, error) {
	jsonBytes, err := base64.StdEncoding.DecodeString(s)
	if err != nil {
		return nil, err
	}

	var m map[string]interface{}
	if err := json.Unmarshal(jsonBytes, &m); err != nil {
		return nil, err
	}

	return m, nil
}
