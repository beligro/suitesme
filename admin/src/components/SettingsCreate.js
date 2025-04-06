import * as React from "react";
import { Create, SimpleForm, TextInput } from "react-admin";

// Создание настройки
export const SettingsCreate = props => (
  <Create {...props}>
    <SimpleForm>
      <TextInput source="key" />
      <TextInput source="value" />
    </SimpleForm>
  </Create>
);
