package external

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"suitesme/internal/config"
	"suitesme/internal/models"
	"suitesme/pkg/logging"
)

type LeadResponse struct {
	ID        int `json:"id"`
	ContactID int `json:"contact_id"`
	CompanyID int `json:"company_id"`
}

type AmoStatus string

const (
	Paid     AmoStatus = "paid"
	GotStyle AmoStatus = "got_style"

	defaultAmoCRMBaseURL = "https://mneidet.amocrm.ru/api/v4"
)

var (
	httpClient    = &http.Client{}
	amoCRMBaseURL = defaultAmoCRMBaseURL
)

func findContact(cfg *config.Config, email string) (*int, error) {
	req, err := http.NewRequest("GET", amoCRMBaseURL+"/contacts", nil)
	if err != nil {
		return nil, err
	}

	query := req.URL.Query()
	query.Add("query", email)
	req.URL.RawQuery = query.Encode()

	req.Header.Set("Authorization", "Bearer "+cfg.AmocrmAccessToken)

	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNoContent {
		return nil, nil
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var result map[string]interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, err
	}

	if embedded, ok := result["_embedded"].(map[string]interface{}); ok {
		if contacts, ok := embedded["contacts"].([]interface{}); ok && len(contacts) > 0 {
			if firstContact, ok := contacts[0].(map[string]interface{}); ok {
				if id, ok := firstContact["id"]; ok {
					switch id.(type) {
					case float64:
						parsedId := int(id.(float64))
						return &parsedId, nil
					case int:
						parsedId := id.(int)
						return &parsedId, nil
					default:
						return nil, fmt.Errorf("unexpected type for id")
					}
				}
			}
		}
	}
	return nil, fmt.Errorf("id not found in response")
}

func createComplexLead(cfg *config.Config, user *models.DbUser, contactId *int) (*int, error) {
	leadData := map[string]interface{}{
		"name":        user.FirstName + " " + user.LastName,
		"pipeline_id": 9313634,
		"status_id":   74695562,
		"_embedded": map[string]interface{}{
			"contacts": []interface{}{},
		},
	}

	contactsEmbedded := leadData["_embedded"].(map[string]interface{})["contacts"].([]interface{})

	if contactId != nil {
		// Если контакт найден, добавляем его ID
		contactsEmbedded = append(contactsEmbedded, map[string]interface{}{
			"id": contactId,
		})
	} else {
		// Если контакт не найден, добавляем всю информацию
		contactsEmbedded = append(contactsEmbedded, map[string]interface{}{
			"first_name": user.FirstName,
			"last_name":  user.LastName,
			"custom_fields_values": []map[string]interface{}{
				{
					"field_code": "EMAIL",
					"values": []map[string]string{
						{
							"enum_code": "WORK",
							"value":     user.Email,
						},
					},
				},
			},
		})
	}

	leadData["_embedded"].(map[string]interface{})["contacts"] = contactsEmbedded

	jsonData, err := json.Marshal([]interface{}{leadData}) // body is an array
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", amoCRMBaseURL+"/leads/complex", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+cfg.AmocrmAccessToken)

	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated && resp.StatusCode != http.StatusAccepted {
		return nil, fmt.Errorf("failed to create lead, status code: %d", resp.StatusCode)
	}

	var leadResponses []LeadResponse
	if err := json.Unmarshal(body, &leadResponses); err != nil {
		return nil, err
	}

	if len(leadResponses) > 0 {
		return &leadResponses[0].ID, nil
	}

	return nil, fmt.Errorf("no lead found in response")
}

func CreateLead(cfg *config.Config, logger *logging.Logger, user *models.DbUser) (*int, error) {
	contactId, err := findContact(cfg, user.Email)
	if err != nil {
		logger.Error(err)
	}

	return createComplexLead(cfg, user, contactId)
}

func UpdateLeadStatus(cfg *config.Config, logger *logging.Logger, leadId int, status AmoStatus, style *string) error {
	var statusId int
	switch status {
	case Paid:
		statusId = 74695566
	case GotStyle:
		statusId = 74695570
	}
	logger.Info("status id is:", statusId)
	leadData := map[string]interface{}{
		"id":                   leadId,
		"status_id":            statusId,
		"custom_fields_values": []map[string]interface{}{},
	}

	if style != nil {
		leadData["custom_fields_values"] = []map[string]interface{}{
			{
				"field_id": 1963419,
				"values": []map[string]string{
					{
						"value": *style,
					},
				},
			},
		}
	}

	jsonData, err := json.Marshal([]interface{}{leadData}) // body is an array
	if err != nil {
		return err
	}
	logger.Infoln(jsonData)

	req, err := http.NewRequest("PATCH", amoCRMBaseURL+"/leads", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+cfg.AmocrmAccessToken)

	resp, err := httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	return nil
}
