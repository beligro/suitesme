import React from 'react';
import ReactDOM from 'react-dom/client'; // Обратите внимание, что мы импортируем из 'react-dom/client'
import App from './App';
import { BrowserRouter } from 'react-router-dom';
import { NavigationHandlerProvider } from './components/NavigationHandlerContext';


const root = ReactDOM.createRoot(document.getElementById('root')); // Создаем "корень"
root.render(
  <React.StrictMode>
    <BrowserRouter>
      <NavigationHandlerProvider>
        <App />
      </NavigationHandlerProvider>
    </BrowserRouter>
  </React.StrictMode>
);
