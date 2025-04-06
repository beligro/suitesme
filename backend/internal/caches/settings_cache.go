package caches

import (
	"suitesme/internal/storage"

	"github.com/patrickmn/go-cache"
)

func UpdateSettingsCache(storage *storage.Storage, c *cache.Cache) {
	settings := storage.Settings.ListAll()

	preparedSettings := make(map[string]string)
	for _, setting := range settings {
		preparedSettings[setting.Key] = setting.Value
	}

	c.Set("settings", preparedSettings, cache.DefaultExpiration)
}

func GetSettingsCache(storage *storage.Storage, c *cache.Cache) map[string]string {
	setting, found := c.Get("settings")
	if found {
		return setting.(map[string]string)
	}
	settings := storage.Settings.ListAll()

	preparedSettings := make(map[string]string)
	for _, sett := range settings {
		preparedSettings[sett.Key] = sett.Value
	}

	return preparedSettings
}
