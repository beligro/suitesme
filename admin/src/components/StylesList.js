import * as React from "react";
import { List, Datagrid, TextField, EditButton } from "react-admin";

// Список стилей
export const StylesList = props => (
  <List {...props}>
    <Datagrid rowClick="edit">
      <TextField source="id" />
      <TextField source="name" />
      <TextField source="comment" />
      <TextField source="pdfInfoUrl" label="PDF URL" />
      <EditButton />
    </Datagrid>
  </List>
);
