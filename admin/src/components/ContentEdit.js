import * as React from "react";
import { Edit, SimpleForm, TextInput } from "react-admin";

// Редактирование контента
export const ContentEdit = props => (
  <Edit {...props}>
    <SimpleForm>
      <TextInput disabled source="id" />
      <TextInput source="key" />
      <TextInput source="ru_value" />
      <TextInput source="en_value" />
    </SimpleForm>
  </Edit>
);
