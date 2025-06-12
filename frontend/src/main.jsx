import React from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import './App.css'
import App from './App.jsx'
import ErrorBoundary from "./components/ErrorBoundary.jsx";
import {AuthProvider} from "./contexts/AuthContext.jsx";
import {NavigationHandlerProvider} from "./components/NavigationHandlerContext.jsx";
import {BrowserRouter} from "react-router-dom";

createRoot(document.getElementById('root')).render(
    <React.StrictMode>
        <ErrorBoundary>
            <BrowserRouter>
                <AuthProvider>
                    <NavigationHandlerProvider>
                        <App />
                    </NavigationHandlerProvider>
                </AuthProvider>
            </BrowserRouter>
        </ErrorBoundary>
    </React.StrictMode>,
)
