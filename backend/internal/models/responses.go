package models

type EmptyResponse struct{}

type ErrorResponse struct {
	Code    int
	Message string
}
