import React, { useEffect } from 'react';
import { Routes, Route } from 'react-router-dom';
import HomePage from './components/HomePage';
import AuthPage from './components/AuthPage';
import ProfilePage from './components/ProfilePage';
import RegisterPage from './components/RegisterPage';
import VerifyEmailPage from './components/VerifyEmailPage';
import ForgotPasswordPage from './components/ForgotPasswordPage';
import PasswordResetPage from './components/PasswordResetPage';
import PaymentRedirect from './components/PaymentRedirect';
import Layout from './components/Layout';
import ProtectedRoute from './components/ProtectedRoute';
import { useNavigationHandler } from './components/NavigationHandlerContext';
import { setNavigationCallback } from './utils/api';
import { useAuth } from './contexts/AuthContext';

// Import global styles
import './styles/global.css';

const App = () => {
  const handleNavigation = useNavigationHandler();
  const { isAuthenticated } = useAuth();

  // Устанавливаем callback для навигации в API
  useEffect(() => {
    setNavigationCallback(handleNavigation);
  }, [handleNavigation]);

  return (
    <Layout>
      <Routes>
        {/* Публичные маршруты */}
        <Route path="/" element={<HomePage />} />
        <Route path="/login" element={<AuthPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/verify_email" element={<VerifyEmailPage />} />
        <Route path="/forgotpassword" element={<ForgotPasswordPage />} />
        <Route path="/password_reset" element={<PasswordResetPage />} />
        
        {/* Защищенные маршруты */}
        <Route element={<ProtectedRoute />}>
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/profile/payment" element={<PaymentRedirect />} />
        </Route>
      </Routes>
    </Layout>
  );
};

export default App;
