package external

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetStyle(t *testing.T) {
	// Execute
	style := GetStyle()

	// Assert
	assert.Equal(t, "style123", style)
}
