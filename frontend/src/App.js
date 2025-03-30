import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import HomePage from './components/HomePage';
import AuthPage from './components/AuthPage';
import ProfilePage from './components/ProfilePage';
import RegisterPage from './components/RegisterPage';
import VerifyEmailPage from './components/VerifyEmailPage';
import ForgotPasswordPage from './components/ForgotPasswordPage';
import PasswordResetPage from './components/PasswordResetPage';
import PaymentRedirect from './components/PaymentRedirect';
import { useNavigationHandler } from './components/NavigationHandlerContext';
import { setNavigationCallback } from './components/axiosConfig';

const App = () => {
  const isAuthorized = localStorage.getItem('isAuthorized') === 'true';
  const handleNavigation = useNavigationHandler();

  setNavigationCallback(handleNavigation);

  return (
    <div>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/login" element={<AuthPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/verify_email" element={<VerifyEmailPage />} />
        <Route path="/forgotpassword" element={<ForgotPasswordPage />} />
        <Route path="/password_reset" element={<PasswordResetPage />} />
        <Route path="/profile/payment" element={<PaymentRedirect />} />
        <Route
          path="/profile"
          element={isAuthorized ? <ProfilePage /> : <Navigate to="/login" />}
        />
      </Routes>
    </div>
  );
};

export default App;
