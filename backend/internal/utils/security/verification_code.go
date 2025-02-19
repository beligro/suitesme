package security

import (
	"math/rand"
	"time"
)

const codeLength = 6

func GetVerificationCode() string {
	rand.New(rand.NewSource(time.Now().UnixNano()))

	digits := "0123456789"
	result := make([]byte, codeLength)
	for idx := range result {
		result[idx] = digits[rand.Intn(len(digits))]
	}

	return string(result)
}
