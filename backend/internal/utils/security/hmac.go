package security

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"sort"
	"strings"
	"suitesme/pkg/logging"
)

type Hmac struct{}

func (h *Hmac) create(data interface{}, key string, algo string) (string, error) {
	if algo != "sha256" {
		return "", fmt.Errorf("unsupported algorithm")
	}

	dataMap, err := toMap(data)
	if err != nil {
		return "", err
	}

	h.sort(dataMap)

	dataJSON, err := json.Marshal(dataMap)
	if err != nil {
		return "", err
	}

	hmac := hmac.New(sha256.New, []byte(key))
	hmac.Write(dataJSON)
	return fmt.Sprintf("%x", hmac.Sum(nil)), nil
}

func (h *Hmac) Verify(data interface{}, key, sign, algo string, logger *logging.Logger) (bool, error) {
	expectedSign, err := h.create(data, key, algo)
	if err != nil {
		return false, err
	}
	logger.Infoln("Sign is: ", expectedSign)
	return strings.EqualFold(expectedSign, sign), nil
}

func (h *Hmac) sort(data map[string]interface{}) {
	keys := make([]string, 0, len(data))
	for k := range data {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	sortedData := make(map[string]interface{})
	for _, k := range keys {
		sortedData[k] = data[k]
		if arr, ok := data[k].([]interface{}); ok {
			sortedArr := make([]interface{}, len(arr))
			for i, v := range arr {
				if m, ok := v.(map[string]interface{}); ok {
					h.sort(m)
				}
				sortedArr[i] = v
			}
			sortedData[k] = sortedArr
		}
	}
	for k, v := range sortedData {
		data[k] = v
	}
}

func toMap(data interface{}) (map[string]interface{}, error) {
	bytes, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	var result map[string]interface{}
	err = json.Unmarshal(bytes, &result)
	return result, err
}
