package security

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestHmac_Verify_Success(t *testing.T) {
	// Setup
	h := &Hmac{}
	key := "test_key"
	data := map[string]interface{}{
		"id":    123,
		"name":  "test",
		"value": 456,
	}

	// Create expected sign using the same method as in the implementation
	// First convert to map and sort it
	dataMap, _ := toMap(data)
	h.sort(dataMap)

	// Then marshal and create HMAC
	dataJSON, _ := json.Marshal(dataMap)
	hmacObj := hmac.New(sha256.New, []byte(key))
	hmacObj.Write(dataJSON)
	expectedSign := fmt.Sprintf("%x", hmacObj.Sum(nil))

	// Execute
	result, err := h.Verify(data, key, expectedSign, "sha256")

	// Assert
	assert.NoError(t, err)
	assert.True(t, result)
}

func TestHmac_Verify_WrongSign(t *testing.T) {
	// Setup
	h := &Hmac{}
	key := "test_key"
	data := map[string]interface{}{
		"id":    123,
		"name":  "test",
		"value": 456,
	}

	// Generate a correct sign first
	correctSign, _ := h.create(data, key, "sha256")

	// Create a wrong sign by modifying the correct one
	wrongSign := correctSign + "abc"

	// Execute
	result, err := h.Verify(data, key, wrongSign, "sha256")

	// Assert
	assert.NoError(t, err)
	assert.False(t, result)
}

func TestHmac_Verify_UnsupportedAlgorithm(t *testing.T) {
	// Setup
	h := &Hmac{}
	key := "test_key"
	data := map[string]interface{}{
		"id":    123,
		"name":  "test",
		"value": 456,
	}
	sign := "some_sign"

	// Execute
	result, err := h.Verify(data, key, sign, "md5")

	// Assert
	assert.Error(t, err)
	assert.False(t, result)
	assert.Contains(t, err.Error(), "unsupported algorithm")
}

func TestHmac_Verify_InvalidData(t *testing.T) {
	// Setup
	h := &Hmac{}
	key := "test_key"
	// Data that can't be marshaled to JSON
	data := struct {
		Ch chan int
	}{
		Ch: make(chan int),
	}
	sign := "some_sign"

	// Execute
	result, err := h.Verify(data, key, sign, "sha256")

	// Assert
	assert.Error(t, err)
	assert.False(t, result)
}

func TestToMap_Success(t *testing.T) {
	// Setup
	type TestStruct struct {
		Name  string `json:"name"`
		Value int    `json:"value"`
	}
	testStruct := TestStruct{
		Name:  "test",
		Value: 123,
	}

	// Execute
	result, err := toMap(testStruct)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, "test", result["name"])
	assert.Equal(t, float64(123), result["value"]) // JSON numbers are float64
}

func TestToMap_Error(t *testing.T) {
	// Setup
	// Create a struct with a channel which cannot be marshaled to JSON
	type BadStruct struct {
		Ch chan int
	}
	badStruct := BadStruct{
		Ch: make(chan int),
	}

	// Execute
	_, err := toMap(badStruct)

	// Assert
	assert.Error(t, err)
}
