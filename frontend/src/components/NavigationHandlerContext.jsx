import React, { createContext, useContext } from 'react';
import { useNavigate } from 'react-router-dom';

const NavigationHandlerContext = createContext();

export const NavigationHandlerProvider = ({ children }) => {
  const navigate = useNavigate();

  const handleNavigation = (url) => {
    navigate(url);
  };

  return (
    <NavigationHandlerContext.Provider value={handleNavigation}>
      {children}
    </NavigationHandlerContext.Provider>
  );
};

export const useNavigationHandler = () => useContext(NavigationHandlerContext);
