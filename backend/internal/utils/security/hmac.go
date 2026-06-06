package security

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"sort"
	"strings"
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

	// Prodamus (PHP json_encode) не экранирует &, <, > — иначе не сойдётся при customer_extra с "&#128525;" и т.п.
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(false)
	if err := enc.Encode(dataMap); err != nil {
		return "", err
	}
	dataJSON := bytes.TrimSpace(buf.Bytes())
	// Prodamus: "В json строке экранируйте /" — иначе подпись не сойдётся при значениях вроде "Visa/Mastercard"
	dataJSON = bytes.ReplaceAll(dataJSON, []byte("/"), []byte("\\/"))

	hmac := hmac.New(sha256.New, []byte(key))
	hmac.Write(dataJSON)
	return fmt.Sprintf("%x", hmac.Sum(nil)), nil
}

func (h *Hmac) Verify(data interface{}, key, sign, algo string) (bool, error) {
	expectedSign, err := h.create(data, key, algo)
	if err != nil {
		return false, err
	}
	return strings.EqualFold(expectedSign, sign), nil
}

// Create returns HMAC-SHA256 signature for data (Prodamus-style: sorted keys, / escaped in JSON).
// Exported for tests and for generating Sign when needed.
func (h *Hmac) Create(data interface{}, key string, algo string) (string, error) {
	return h.create(data, key, algo)
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
