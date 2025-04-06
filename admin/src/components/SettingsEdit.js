import * as React from "react";
import { Edit, SimpleForm, TextInput } from "react-admin";

// Редактирование настроек
export const SettingsEdit = props => (
  <Edit {...props}>
    <SimpleForm>
      <TextInput disabled source="id" />
      <TextInput source="key" />
      <TextInput source="value" />
    </SimpleForm>
  </Edit>
);
