package security

import (
	"encoding/base64"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	"github.com/thanhpk/randstr"
)

type ResetTokenStruct struct {
	UserId     uuid.UUID
	ResetToken string
}

func GetResetToken() string {
	return randstr.String(20)
}

func Encode(resetTokenInfo *ResetTokenStruct) (string, error) {
	jsonData, err := json.Marshal(*resetTokenInfo)
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(jsonData), nil
}

func Decode(tokenStr string) (*ResetTokenStruct, error) {
	decodedData, err := base64.StdEncoding.DecodeString(tokenStr)
	if err != nil {
		return nil, err
	}

	var decodedStruct ResetTokenStruct
	err = json.Unmarshal(decodedData, &decodedStruct)
	if err != nil {
		return nil, err
	}

	fmt.Println(decodedStruct)

	return &decodedStruct, nil
}
