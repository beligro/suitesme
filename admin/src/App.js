import * as React from "react";
import { Admin, Resource } from "react-admin";
import AuthProvider from "./components/AuthProvider";
import dataProvider from "./dataProvider";
import { ContentCreate } from "./components/ContentCreate";
import { ContentList } from "./components/ContentList";
import { ContentEdit } from "./components/ContentEdit";
import { SettingsCreate } from "./components/SettingsCreate";
import { SettingsList } from "./components/SettingsList";
import { SettingsEdit } from "./components/SettingsEdit";
import { StylesCreate } from "./components/StylesCreate";
import { StylesList } from "./components/StylesList";
import { StylesEdit } from "./components/StylesEdit";

const App = () => (
  <Admin dataProvider={dataProvider} authProvider={AuthProvider}>
    <Resource name="content" list={ContentList} edit={ContentEdit} create={ContentCreate} />
    <Resource name="settings" list={SettingsList} edit={SettingsEdit} create={SettingsCreate} />
    <Resource name="styles" list={StylesList} edit={StylesEdit} create={StylesCreate} />
  </Admin>
);

export default App;
