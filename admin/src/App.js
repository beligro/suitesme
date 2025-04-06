import * as React from "react";
import { Admin, Resource, fetchUtils } from "react-admin";
import jsonServerProvider from "ra-data-json-server";
import AuthProvider from "./components/AuthProvider";
import { ContentCreate } from "./components/ContentCreate";
import { ContentList } from "./components/ContentList";
import { ContentEdit } from "./components/ContentEdit";
import { SettingsCreate } from "./components/SettingsCreate";
import { SettingsList } from "./components/SettingsList";
import { SettingsEdit } from "./components/SettingsEdit";

const httpClient = (url, options = {}) => {
  if (!options.headers) {
      options.headers = new Headers({ 'Content-Type': 'application/json' });
  }
  const token = localStorage.getItem('auth');
  options.headers.set('Authorization', `Bearer ${token}`);
  return fetchUtils.fetchJson(url, options);
};

const dataProvider = jsonServerProvider('http://51.250.84.195:8080/admin/v1', httpClient);

const App = () => (
  <Admin dataProvider={dataProvider} authProvider={AuthProvider}>
    <Resource name="content" list={ContentList} edit={ContentEdit} create={ContentCreate} />
    <Resource name="settings" list={SettingsList} edit={SettingsEdit} create={SettingsCreate} />
  </Admin>
);

export default App;
