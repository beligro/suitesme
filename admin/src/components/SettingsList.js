import * as React from "react";
import { List, Datagrid, TextField, EditButton } from "react-admin";

// Список настроек
export const SettingsList = props => (
  <List {...props}>
    <Datagrid rowClick="edit">
      <TextField source="id" />
      <TextField source="key" />
      <TextField source="value" />
      <EditButton />
    </Datagrid>
  </List>
);
