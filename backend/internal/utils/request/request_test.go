package request

import (
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
)

// Test struct
type TestRequest struct {
	Name  string `json:"name" validate:"required"`
	Email string `json:"email" validate:"required,email"`
}

// Custom echo.Context implementation for testing
type testContext struct {
	echo.Context
	bindFunc     func(interface{}) error
	validateFunc func(interface{}) error
}

func (c *testContext) Bind(i interface{}) error {
	return c.bindFunc(i)
}

func (c *testContext) Validate(i interface{}) error {
	return c.validateFunc(i)
}

func setupTest(t *testing.T, bindErr, validateErr error) (*echo.Context, *TestRequest) {
	// Create a new echo instance
	e := echo.New()

	// Create a new request with a JSON body
	req := httptest.NewRequest(http.MethodPost, "/", strings.NewReader(`{"name":"test","email":"test@example.com"}`))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)

	// Create a response recorder
	rec := httptest.NewRecorder()

	// Create a new context
	c := e.NewContext(req, rec)

	// Create a test context with custom bind and validate functions
	tc := &testContext{
		Context: c,
		bindFunc: func(i interface{}) error {
			if bindErr != nil {
				return bindErr
			}

			// If no error, populate the struct with test data
			if req, ok := i.(*TestRequest); ok {
				req.Name = "test"
				req.Email = "test@example.com"
			}

			return nil
		},
		validateFunc: func(i interface{}) error {
			return validateErr
		},
	}

	// Create a pointer to the test context
	ctxPtr := echo.Context(tc)

	// Create a test request
	testReq := &TestRequest{}

	return &ctxPtr, testReq
}

func TestParseRequest_Success(t *testing.T) {
	// Setup
	ctxPtr, _ := setupTest(t, nil, nil)

	// Execute
	result, err := ParseRequest[TestRequest](ctxPtr)

	// Assert
	assert.NoError(t, err)
	assert.NotNil(t, result)
	if result != nil {
		assert.Equal(t, "test", result.Name)
		assert.Equal(t, "test@example.com", result.Email)
	}
}

func TestParseRequest_BindError(t *testing.T) {
	// Setup
	ctxPtr, _ := setupTest(t, errors.New("bind error"), nil)

	// Execute
	result, err := ParseRequest[TestRequest](ctxPtr)

	// Assert
	// In the current implementation, ParseRequest returns nil error
	// because it sends a JSON response to the client instead
	assert.Nil(t, err)
	assert.Nil(t, result)
}

func TestParseRequest_ValidationError(t *testing.T) {
	// Setup
	ctxPtr, _ := setupTest(t, nil, errors.New("validation error"))

	// Execute
	result, err := ParseRequest[TestRequest](ctxPtr)

	// Assert
	// In the current implementation, ParseRequest returns nil error
	// because it sends a JSON response to the client instead
	assert.Nil(t, err)
	assert.Nil(t, result)
}
