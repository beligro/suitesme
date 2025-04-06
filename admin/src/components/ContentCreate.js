import * as React from "react";
import { Create, SimpleForm, TextInput } from "react-admin";

// Создание контента
export const ContentCreate = props => (
  <Create {...props}>
    <SimpleForm>
      <TextInput source="key" />
      <TextInput source="ru_value" />
      <TextInput source="en_value" />
    </SimpleForm>
  </Create>
);
