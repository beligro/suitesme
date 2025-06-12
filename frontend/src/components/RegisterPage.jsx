import React, { useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import api from '../utils/api.js';
import { useAuth } from '../contexts/AuthContext.jsx';
import useForm from '../hooks/useForm.js';
import './RegisterPage.css';

const RegisterPage = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();

  // Начальные значения формы
  const initialValues = {
    first_name: '',
    last_name: '',
    birth_date: '',
    email: '',
    password: '',
    password_confirm: ''
  };

  // Правила валидации для формы регистрации
  const validationRules = {
    first_name: [
      { type: 'required', message: 'Имя обязательно' }
    ],
    last_name: [
      { type: 'required', message: 'Фамилия обязательна' }
    ],
    birth_date: [
      { type: 'required', message: 'Дата рождения обязательна' },
      { type: 'date', message: 'Некорректная дата рождения' }
    ],
    email: [
      { type: 'required', message: 'Email обязателен' },
      { type: 'email', message: 'Некорректный формат email' }
    ],
    password: [
      { type: 'required', message: 'Пароль обязателен' },
      { type: 'minLength', value: 6, message: 'Пароль должен содержать минимум 6 символов' }
    ],
    password_confirm: [
      { type: 'required', message: 'Подтверждение пароля обязательно' },
      { type: 'match', field: 'password', message: 'Пароли не совпадают' }
    ]
  };

  // Обработчик отправки формы
  const handleRegisterSubmit = async (values) => {
    try {
      const response = await api.post('/api/v1/auth/register', values);
      
      // Сохраняем ID пользователя для верификации email
      localStorage.setItem('userId', response.data.user_id);
      
      // Перенаправляем на страницу верификации email с передачей данных
      navigate('/verify_email', {
        state: {
          email: values.email,
          password: values.password
        }
      });
      
      return response.data;
    } catch (error) {
      console.error('Ошибка регистрации:', error);
      
      // Обрабатываем ошибку конфликта (пользователь уже существует)
      if (error.response?.status === 409) {
        throw new Error('Пользователь с таким email уже существует');
      }
      
      throw new Error(error.response?.data?.message || 'Ошибка при регистрации. Пожалуйста, попробуйте снова.');
    }
  };

  // Инициализируем хук формы
  const { 
    values, 
    errors, 
    isSubmitting, 
    handleChange, 
    handleSubmit 
  } = useForm(
    initialValues, 
    validationRules, 
    handleRegisterSubmit
  );

  // Если пользователь уже авторизован, перенаправляем на страницу профиля
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/profile');
    }
  }, [isAuthenticated, navigate]);

  return (
    <div className="register-page">
      <div className="auth-card">
        <div className="auth-header">
          <h2 className="auth-title">Регистрация</h2>
          <p className="auth-subtitle">Создайте аккаунт, чтобы начать пользоваться сервисом</p>
        </div>

        {errors._general && <div className="alert alert-error">{errors._general}</div>}

        <form className="auth-form" onSubmit={handleSubmit}>
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="first_name">Имя</label>
              <input 
                id="first_name"
                name="first_name" 
                type="text" 
                value={values.first_name}
                onChange={handleChange} 
                placeholder="Введите имя" 
                disabled={isSubmitting}
              />
              {errors.first_name && <div className="form-error">{errors.first_name}</div>}
            </div>

            <div className="form-group">
              <label htmlFor="last_name">Фамилия</label>
              <input 
                id="last_name"
                name="last_name" 
                type="text" 
                value={values.last_name}
                onChange={handleChange} 
                placeholder="Введите фамилию" 
                disabled={isSubmitting}
              />
              {errors.last_name && <div className="form-error">{errors.last_name}</div>}
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="birth_date">Дата рождения</label>
            <input 
              id="birth_date"
              name="birth_date" 
              type="date" 
              value={values.birth_date}
              onChange={handleChange} 
              disabled={isSubmitting}
            />
            {errors.birth_date && <div className="form-error">{errors.birth_date}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input 
              id="email"
              name="email" 
              type="email" 
              value={values.email}
              onChange={handleChange} 
              placeholder="Введите email" 
              disabled={isSubmitting}
            />
            {errors.email && <div className="form-error">{errors.email}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="password">Пароль</label>
            <input 
              id="password"
              name="password" 
              type="password" 
              value={values.password}
              onChange={handleChange} 
              placeholder="Введите пароль" 
              disabled={isSubmitting}
            />
            {errors.password && <div className="form-error">{errors.password}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="password_confirm">Подтверждение пароля</label>
            <input 
              id="password_confirm"
              name="password_confirm" 
              type="password" 
              value={values.password_confirm}
              onChange={handleChange} 
              placeholder="Подтвердите пароль" 
              disabled={isSubmitting}
            />
            {errors.password_confirm && <div className="form-error">{errors.password_confirm}</div>}
          </div>

          <div className="form-actions">
            <button 
              type="submit" 
              className="btn btn-primary btn-lg w-full" 
              disabled={isSubmitting}
            >
              {isSubmitting ? 'Регистрация...' : 'Зарегистрироваться'}
            </button>
          </div>
        </form>

        <div className="auth-footer">
          <div className="auth-separator">
            <span>Уже есть аккаунт?</span>
          </div>
          <Link to="/login" className="btn btn-outline w-full">Войти</Link>
        </div>
      </div>
    </div>
  );
};

export default RegisterPage;
