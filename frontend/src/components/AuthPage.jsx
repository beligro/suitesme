import React, { useEffect } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import api from '../utils/api.js';
import { useAuth } from '../contexts/AuthContext.jsx';
import useForm from '../hooks/useForm.js';
import { validateForm } from '../utils/validation.js';
import './AuthPage.css';

const AuthPage = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { isAuthenticated, login } = useAuth();

  // Правила валидации для формы входа
  const validationRules = {
    email: [
      { type: 'required', message: 'Email обязателен' },
      { type: 'email', message: 'Некорректный формат email' }
    ],
    password: [
      { type: 'required', message: 'Пароль обязателен' }
    ]
  };

  // Обработчик отправки формы
  const handleLoginSubmit = async (values) => {
    try {
      const response = await api.post('/api/v1/auth/login', {
        email: values.email,
        password: values.password
      });
      
      const { access_token, refresh_token } = response.data;
      
      // Используем функцию login из контекста аутентификации
      login(access_token, refresh_token);
      
      // Перенаправляем на страницу профиля
      navigate('/profile');
      
      return response.data;
    } catch (error) {
      console.error('Ошибка авторизации:', error);
      throw new Error(error.response?.data?.message || 'Ошибка авторизации. Проверьте введенные данные.');
    }
  };

  // Инициализируем хук формы
  const { 
    values, 
    errors, 
    isSubmitting, 
    handleChange, 
    handleSubmit,
    setAllValues
  } = useForm(
    { email: '', password: '' }, 
    validationRules, 
    handleLoginSubmit
  );

  // Если пользователь уже авторизован, перенаправляем на страницу профиля
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/profile');
    }
  }, [isAuthenticated, navigate]);

  // Если есть данные в location.state, используем их для автоматического входа
  useEffect(() => {
    if (location.state) {
      const { email, password } = location.state;
      if (email && password) {
        setAllValues({ email, password });
        handleSubmit();
      }
    }
  }, [location.state, setAllValues, handleSubmit]);

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-header">
          <h2 className="auth-title">Вход в аккаунт</h2>
          <p className="auth-subtitle">Введите свои данные для входа</p>
        </div>

        {errors._general && <div className="alert alert-error">{errors._general}</div>}

        <form className="auth-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input 
              type="email" 
              id="email"
              name="email"
              value={values.email} 
              onChange={handleChange} 
              placeholder="Введите ваш email" 
              disabled={isSubmitting}
            />
            {errors.email && <div className="form-error">{errors.email}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="password">Пароль</label>
            <input 
              type="password" 
              id="password"
              name="password"
              value={values.password} 
              onChange={handleChange} 
              placeholder="Введите ваш пароль" 
              disabled={isSubmitting}
            />
            {errors.password && <div className="form-error">{errors.password}</div>}
          </div>

          <div className="form-actions">
            <button 
              type="submit" 
              className="btn btn-primary btn-lg w-full" 
              disabled={isSubmitting}
            >
              {isSubmitting ? 'Вход...' : 'Войти'}
            </button>
          </div>
        </form>

        <div className="auth-footer">
          <Link to="/forgotpassword" className="auth-link">Забыли пароль?</Link>
          <div className="auth-separator">
            <span>Нет аккаунта?</span>
          </div>
          <Link to="/register" className="btn btn-outline w-full">Зарегистрироваться</Link>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
