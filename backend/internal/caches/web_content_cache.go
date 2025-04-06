package caches

import (
	"suitesme/internal/models"
	"suitesme/internal/storage"

	"github.com/patrickmn/go-cache"
)

func UpdateWebContentCache(storage *storage.Storage, c *cache.Cache) {
	content := storage.WebContent.ListAll()

	preparedContent := make(map[string]models.WebContentCacheItem)
	for _, cont := range content {
		preparedContent[cont.Key] = models.WebContentCacheItem{RuValue: cont.RuValue, EnValue: cont.EnValue}
	}

	c.Set("content", preparedContent, cache.DefaultExpiration)
}

func GetWebContentCache(storage *storage.Storage, c *cache.Cache) map[string]models.WebContentCacheItem {
	content, found := c.Get("content")
	if found {
		return content.(map[string]models.WebContentCacheItem)
	}
	contents := storage.WebContent.ListAll()

	preparedContent := make(map[string]models.WebContentCacheItem)
	for _, cont := range contents {
		preparedContent[cont.Key] = models.WebContentCacheItem{RuValue: cont.RuValue, EnValue: cont.EnValue}
	}

	return preparedContent
}
