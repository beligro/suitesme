import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import Cookies from 'js-cookie';
import { useNavigate } from 'react-router-dom';

// Create context
const AuthContext = createContext(null);

// Custom hook to use the auth context
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  // Initialize auth state from cookies
  useEffect(() => {
    const checkAuth = () => {
      const accessToken = Cookies.get('access_token');
      const refreshToken = Cookies.get('refresh_token');
      
      // Consider authenticated if both tokens exist
      const authenticated = !!(accessToken && refreshToken);
      setIsAuthenticated(authenticated);
      
      // Update localStorage for backward compatibility
      localStorage.setItem('isAuthorized', authenticated ? 'true' : 'false');
      
      setIsLoading(false);
    };
    
    checkAuth();
  }, []);

  // Login function
  const login = useCallback((accessToken, refreshToken) => {
    if (!accessToken || !refreshToken) {
      throw new Error('Access token and refresh token are required');
    }
    
    // Set cookies with secure options
    Cookies.set('access_token', accessToken, { 
      secure: window.location.protocol === 'https:',
      sameSite: 'strict'
    });
    Cookies.set('refresh_token', refreshToken, { 
      secure: window.location.protocol === 'https:',
      sameSite: 'strict'
    });
    
    setIsAuthenticated(true);
    localStorage.setItem('isAuthorized', 'true');
  }, []);

  // Logout function
  const logout = useCallback(() => {
    Cookies.remove('access_token');
    Cookies.remove('refresh_token');
    setIsAuthenticated(false);
    localStorage.setItem('isAuthorized', 'false');
    navigate('/login');
  }, [navigate]);

  // Update tokens (for token refresh)
  const updateTokens = useCallback((accessToken, refreshToken) => {
    if (!accessToken || !refreshToken) {
      throw new Error('Access token and refresh token are required');
    }
    
    Cookies.set('access_token', accessToken, { 
      secure: window.location.protocol === 'https:',
      sameSite: 'strict'
    });
    Cookies.set('refresh_token', refreshToken, { 
      secure: window.location.protocol === 'https:',
      sameSite: 'strict'
    });
  }, []);

  // Get tokens
  const getTokens = useCallback(() => {
    return {
      accessToken: Cookies.get('access_token'),
      refreshToken: Cookies.get('refresh_token')
    };
  }, []);

  const value = {
    isAuthenticated,
    isLoading,
    login,
    logout,
    updateTokens,
    getTokens
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
