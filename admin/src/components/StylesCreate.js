import * as React from "react";
import { Create, SimpleForm, TextInput, FileInput, FileField } from "react-admin";

// Создание стиля
export const StylesCreate = props => (
  <Create {...props}>
    <SimpleForm>
      <TextInput source="name" />
      <TextInput multiline source="comment" />
      <FileInput source="pdf_file" label="PDF File" accept="application/pdf" required>
        <FileField source="src" title="title" />
      </FileInput>
    </SimpleForm>
  </Create>
);
