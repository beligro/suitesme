import React from 'react'
import './App.css'
import './index.css'
import AppRouter from "./app/routes/AppRouter.jsx";
import {Provider} from "react-redux";
import {store} from "./app/store";

function App() {

    return (
        <Provider store={store}>
            <AppRouter />
        </Provider>
    );
};

export default App