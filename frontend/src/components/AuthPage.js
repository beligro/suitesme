import React, { useState, useEffect, useCallback } from 'react';
import axiosInstance from './axiosConfig';
import { useNavigate, useLocation } from 'react-router-dom';
import Cookies from 'js-cookie';

const AuthPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();
  const location = useLocation();
  const isAuthorized = localStorage.getItem('isAuthorized') === 'true';

  const handleLogin = useCallback(async (emailToUse = email, passwordToUse = password) => {
    try {
      const response = await axiosInstance.post('/api/v1/auth/login', { email: emailToUse, password: passwordToUse });
      const { access_token, refresh_token } = response.data;

      Cookies.set('access_token', access_token); // Без httpOnly
      Cookies.set('refresh_token', refresh_token);

      localStorage.setItem('isAuthorized', 'true');
      navigate('/profile');
    } catch (error) {
      console.error('Ошибка авторизации:', error);
    }
  }, [email, password, navigate]);

  useEffect(() => {
    if (isAuthorized) {
      navigate('/profile');
    }
    if (location.state) {
      const { email: passedEmail, password: passedPassword } = location.state;
      if (passedEmail && passedPassword) {
        setEmail(passedEmail);
        setPassword(passedPassword);
        handleLogin(passedEmail, passedPassword);
      }
    }
  }, [location, handleLogin, isAuthorized, navigate]);

  return (
    <div>
      <h2>Авторизация</h2>
      <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" />
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Пароль" />
      <button onClick={() => handleLogin()}>Войти</button>
      <button onClick={() => navigate('/forgotpassword')}>Забыли пароль?</button>
    </div>
  );
};

export default AuthPage;