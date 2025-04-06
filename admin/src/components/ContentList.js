import * as React from "react";
import { List, Datagrid, TextField, EditButton } from "react-admin";

// Список контента
export const ContentList = props => (
  <List {...props}>
    <Datagrid rowClick="edit">
      <TextField source="id" />
      <TextField source="key" />
      <TextField source="ru_value" />
      <TextField source="en_value" />
      <EditButton />
    </Datagrid>
  </List>
);
