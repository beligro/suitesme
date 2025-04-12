package helper

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestStructToString_Success(t *testing.T) {
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
	result := StructToString(testStruct)

	// Assert
	expected, _ := json.MarshalIndent(testStruct, "", "  ")
	assert.Equal(t, string(expected), result)
}

func TestStructToString_Error(t *testing.T) {
	// Setup
	// Create a struct with a channel which cannot be marshaled to JSON
	type BadStruct struct {
		Ch chan int
	}
	badStruct := BadStruct{
		Ch: make(chan int),
	}

	// Execute
	result := StructToString(badStruct)

	// Assert
	assert.Equal(t, "", result)
}

func TestStructToString_Nil(t *testing.T) {
	// Execute
	result := StructToString(nil)

	// Assert
	assert.Equal(t, "null", result)
}

func TestStructToString_EmptyStruct(t *testing.T) {
	// Setup
	type EmptyStruct struct{}
	emptyStruct := EmptyStruct{}

	// Execute
	result := StructToString(emptyStruct)

	// Assert
	assert.Equal(t, "{}", result)
}
