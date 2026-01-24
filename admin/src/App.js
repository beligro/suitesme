import * as React from "react";
import { Admin, Resource, CustomRoutes } from "react-admin";
import { Route } from "react-router-dom";
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
import { PredictionsList } from "./components/PredictionsList";
import { PredictionsEdit } from "./components/PredictionsEdit";
import { PredictionsStatistics } from "./components/PredictionsStatistics";

const App = () => (
  <Admin dataProvider={dataProvider} authProvider={AuthProvider}>
    <Resource name="content" list={ContentList} edit={ContentEdit} create={ContentCreate} />
    <Resource name="settings" list={SettingsList} edit={SettingsEdit} create={SettingsCreate} />
    <Resource name="styles" list={StylesList} edit={StylesEdit} create={StylesCreate} />
    <Resource name="predictions" list={PredictionsList} edit={PredictionsEdit} />
    <CustomRoutes>
      <Route path="/predictions-statistics" element={<PredictionsStatistics />} />
    </CustomRoutes>
  </Admin>
);

export default App;
