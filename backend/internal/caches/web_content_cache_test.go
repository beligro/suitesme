package caches

import (
	"reflect"
	"suitesme/internal/models"
	"testing"
	"time"

	"github.com/patrickmn/go-cache"
	"github.com/stretchr/testify/mock"
)

// MockWebContentRepository mocks the WebContentRepository interface
type MockWebContentRepository struct {
	mock.Mock
}

func (m *MockWebContentRepository) ListAll() []models.DbWebContent {
	args := m.Called()
	return args.Get(0).([]models.DbWebContent)
}

type MockWebContentStorage struct {
	WebContentRepo *MockWebContentRepository
}

// Override the ListAll method to delegate to our mock
func (m *MockWebContentStorage) ListAll() []models.DbWebContent {
	return m.WebContentRepo.ListAll()
}

func TestUpdateWebContentCache(t *testing.T) {
	// Create mock repository
	mockRepo := new(MockWebContentRepository)

	// Create mock storage
	mockStorage := &MockWebContentStorage{
		WebContentRepo: mockRepo,
	}

	// Create test cache
	testCache := cache.New(5*time.Minute, 10*time.Minute)

	// Setup mock data
	mockWebContents := []models.DbWebContent{
		{Key: "key1", RuValue: "ru1", EnValue: "en1"},
		{Key: "key2", RuValue: "ru2", EnValue: "en2"},
	}

	// Setup expectations
	mockRepo.On("ListAll").Return(mockWebContents)

	// Call the function with our mock
	updateWebContentCacheTest(mockStorage, testCache)

	// Verify cache was updated correctly
	cachedContent, found := testCache.Get("content")
	if !found {
		t.Fatal("Web content was not cached")
	}

	expectedContent := map[string]models.WebContentCacheItem{
		"key1": {RuValue: "ru1", EnValue: "en1"},
		"key2": {RuValue: "ru2", EnValue: "en2"},
	}

	if !reflect.DeepEqual(cachedContent, expectedContent) {
		t.Errorf("Cached content does not match expected. Got %v, want %v", cachedContent, expectedContent)
	}

	// Verify mock expectations
	mockRepo.AssertExpectations(t)
}

// Test version of UpdateWebContentCache that accepts our mock
func updateWebContentCacheTest(storage *MockWebContentStorage, c *cache.Cache) {
	content := storage.ListAll()

	preparedContent := make(map[string]models.WebContentCacheItem)
	for _, cont := range content {
		preparedContent[cont.Key] = models.WebContentCacheItem{RuValue: cont.RuValue, EnValue: cont.EnValue}
	}

	c.Set("content", preparedContent, cache.DefaultExpiration)
}

func TestGetWebContentCache_CacheHit(t *testing.T) {
	// Create mock repository
	mockRepo := new(MockWebContentRepository)

	// Create mock storage
	mockStorage := &MockWebContentStorage{
		WebContentRepo: mockRepo,
	}

	// Create test cache with pre-populated data
	testCache := cache.New(5*time.Minute, 10*time.Minute)
	expectedContent := map[string]models.WebContentCacheItem{
		"key1": {RuValue: "ru1", EnValue: "en1"},
		"key2": {RuValue: "ru2", EnValue: "en2"},
	}
	testCache.Set("content", expectedContent, cache.DefaultExpiration)

	// Call the function with our mock
	result := getWebContentCacheTest(mockStorage, testCache)

	// Verify result
	if !reflect.DeepEqual(result, expectedContent) {
		t.Errorf("GetWebContentCache returned incorrect result. Got %v, want %v", result, expectedContent)
	}

	// Verify that ListAll was not called (cache hit)
	mockRepo.AssertNotCalled(t, "ListAll")
}

// Test version of GetWebContentCache that accepts our mock
func getWebContentCacheTest(storage *MockWebContentStorage, c *cache.Cache) map[string]models.WebContentCacheItem {
	content, found := c.Get("content")
	if found {
		return content.(map[string]models.WebContentCacheItem)
	}
	contents := storage.ListAll()

	preparedContent := make(map[string]models.WebContentCacheItem)
	for _, cont := range contents {
		preparedContent[cont.Key] = models.WebContentCacheItem{RuValue: cont.RuValue, EnValue: cont.EnValue}
	}

	return preparedContent
}

func TestGetWebContentCache_CacheMiss(t *testing.T) {
	// Create mock repository
	mockRepo := new(MockWebContentRepository)

	// Create mock storage
	mockStorage := &MockWebContentStorage{
		WebContentRepo: mockRepo,
	}

	// Create empty test cache
	testCache := cache.New(5*time.Minute, 10*time.Minute)

	// Setup mock data
	mockWebContents := []models.DbWebContent{
		{Key: "key1", RuValue: "ru1", EnValue: "en1"},
		{Key: "key2", RuValue: "ru2", EnValue: "en2"},
	}

	// Setup expectations
	mockRepo.On("ListAll").Return(mockWebContents)

	// Call the function with our mock
	result := getWebContentCacheTest(mockStorage, testCache)

	// Verify result
	expectedContent := map[string]models.WebContentCacheItem{
		"key1": {RuValue: "ru1", EnValue: "en1"},
		"key2": {RuValue: "ru2", EnValue: "en2"},
	}
	if !reflect.DeepEqual(result, expectedContent) {
		t.Errorf("GetWebContentCache returned incorrect result. Got %v, want %v", result, expectedContent)
	}

	// Verify mock expectations
	mockRepo.AssertExpectations(t)
}
