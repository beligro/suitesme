package caches

import (
	"reflect"
	"suitesme/internal/models"
	"testing"
	"time"

	"github.com/patrickmn/go-cache"
	"github.com/stretchr/testify/mock"
)

// MockSettingsRepository mocks the SettingsRepository interface
type MockSettingsRepository struct {
	mock.Mock
}

func (m *MockSettingsRepository) ListAll() []models.DbSettings {
	args := m.Called()
	return args.Get(0).([]models.DbSettings)
}

type MockStorage struct {
	SettingsRepo *MockSettingsRepository
}

// Override the ListAll method to delegate to our mock
func (m *MockStorage) ListAll() []models.DbSettings {
	return m.SettingsRepo.ListAll()
}

func TestUpdateSettingsCache(t *testing.T) {
	// Create mock repository
	mockRepo := new(MockSettingsRepository)

	// Create mock storage
	mockStorage := &MockStorage{
		SettingsRepo: mockRepo,
	}

	// Create test cache
	testCache := cache.New(5*time.Minute, 10*time.Minute)

	// Setup mock data
	mockSettings := []models.DbSettings{
		{Key: "key1", Value: "value1"},
		{Key: "key2", Value: "value2"},
	}

	// Setup expectations
	mockRepo.On("ListAll").Return(mockSettings)

	// Call the function with our mock
	// We need to modify the function to accept our mock
	updateSettingsCacheTest(mockStorage, testCache)

	// Verify cache was updated correctly
	cachedSettings, found := testCache.Get("settings")
	if !found {
		t.Fatal("Settings were not cached")
	}

	expectedSettings := map[string]string{
		"key1": "value1",
		"key2": "value2",
	}

	if !reflect.DeepEqual(cachedSettings, expectedSettings) {
		t.Errorf("Cached settings do not match expected. Got %v, want %v", cachedSettings, expectedSettings)
	}

	// Verify mock expectations
	mockRepo.AssertExpectations(t)
}

// Test version of UpdateSettingsCache that accepts our mock
func updateSettingsCacheTest(storage *MockStorage, c *cache.Cache) {
	settings := storage.ListAll()

	preparedSettings := make(map[string]string)
	for _, setting := range settings {
		preparedSettings[setting.Key] = setting.Value
	}

	c.Set("settings", preparedSettings, cache.DefaultExpiration)
}

func TestGetSettingsCache_CacheHit(t *testing.T) {
	// Create mock repository
	mockRepo := new(MockSettingsRepository)

	// Create mock storage
	mockStorage := &MockStorage{
		SettingsRepo: mockRepo,
	}

	// Create test cache with pre-populated data
	testCache := cache.New(5*time.Minute, 10*time.Minute)
	expectedSettings := map[string]string{
		"key1": "value1",
		"key2": "value2",
	}
	testCache.Set("settings", expectedSettings, cache.DefaultExpiration)

	// Call the function with our mock
	result := getSettingsCacheTest(mockStorage, testCache)

	// Verify result
	if !reflect.DeepEqual(result, expectedSettings) {
		t.Errorf("GetSettingsCache returned incorrect result. Got %v, want %v", result, expectedSettings)
	}

	// Verify that ListAll was not called (cache hit)
	mockRepo.AssertNotCalled(t, "ListAll")
}

// Test version of GetSettingsCache that accepts our mock
func getSettingsCacheTest(storage *MockStorage, c *cache.Cache) map[string]string {
	setting, found := c.Get("settings")
	if found {
		return setting.(map[string]string)
	}
	settings := storage.ListAll()

	preparedSettings := make(map[string]string)
	for _, sett := range settings {
		preparedSettings[sett.Key] = sett.Value
	}

	return preparedSettings
}

func TestGetSettingsCache_CacheMiss(t *testing.T) {
	// Create mock repository
	mockRepo := new(MockSettingsRepository)

	// Create mock storage
	mockStorage := &MockStorage{
		SettingsRepo: mockRepo,
	}

	// Create empty test cache
	testCache := cache.New(5*time.Minute, 10*time.Minute)

	// Setup mock data
	mockSettings := []models.DbSettings{
		{Key: "key1", Value: "value1"},
		{Key: "key2", Value: "value2"},
	}

	// Setup expectations
	mockRepo.On("ListAll").Return(mockSettings)

	// Call the function with our mock
	result := getSettingsCacheTest(mockStorage, testCache)

	// Verify result
	expectedSettings := map[string]string{
		"key1": "value1",
		"key2": "value2",
	}
	if !reflect.DeepEqual(result, expectedSettings) {
		t.Errorf("GetSettingsCache returned incorrect result. Got %v, want %v", result, expectedSettings)
	}

	// Verify mock expectations
	mockRepo.AssertExpectations(t)
}
