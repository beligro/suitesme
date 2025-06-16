import * as React from "react";
import { Edit, SimpleForm, TextInput, FileInput, FileField } from "react-admin";

// Редактирование стиля
export const StylesEdit = props => (
  <Edit {...props}>
    <SimpleForm>
      <TextInput disabled source="id" />
      <TextInput source="name" />
      <TextInput multiline source="comment" />
      <FileInput source="pdf_file" label="PDF File" accept="application/pdf">
        <FileField source="src" title="title" />
      </FileInput>
      <TextInput disabled source="pdfInfoUrl" label="Current PDF URL" />
    </SimpleForm>
  </Edit>
);
