import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { publicApi } from '../utils/api.js';
import useForm from '../hooks/useForm.js';
import './AuthPage.css'; // Reuse auth page styles

const ForgotPasswordPage = () => {
  const [successMessage, setSuccessMessage] = useState('');

  // Правила валидации для формы восстановления пароля
  const validationRules = {
    email: [
      { type: 'required', message: 'Email обязателен' },
      { type: 'email', message: 'Некорректный формат email' }
    ]
  };

  // Обработчик отправки формы
  const handleForgotPasswordSubmit = async (values) => {
    try {
      await publicApi.post('/api/v1/auth/forgot_password', { email: values.email });
      setSuccessMessage('Письмо отправлено! Перейдите по ссылке из письма для восстановления пароля.');
      return true;
    } catch (error) {
      console.error('Ошибка при отправке письма для восстановления пароля:', error);
      throw new Error('Не удалось отправить письмо. Пожалуйста, проверьте email и попробуйте снова.');
    }
  };

  // Инициализируем хук формы
  const { 
    values, 
    errors, 
    isSubmitting,
    isSubmitted,
    handleChange, 
    handleSubmit 
  } = useForm(
    { email: '' }, 
    validationRules, 
    handleForgotPasswordSubmit
  );

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-header">
          <h2 className="auth-title">Восстановление пароля</h2>
          <p className="auth-subtitle">Введите ваш email для получения инструкций по восстановлению пароля</p>
        </div>
        
        {errors._general && <div className="alert alert-error">{errors._general}</div>}
        {(successMessage || isSubmitted) && (
          <div className="alert alert-success">
            {successMessage || 'Письмо отправлено! Перейдите по ссылке из письма для восстановления пароля.'}
          </div>
        )}
        
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
              disabled={isSubmitting || isSubmitted}
            />
            {errors.email && <div className="form-error">{errors.email}</div>}
          </div>
          
          <div className="form-actions">
            <button 
              type="submit" 
              className="btn btn-primary btn-lg w-full" 
              disabled={isSubmitting || isSubmitted}
            >
              {isSubmitting ? 'Отправка...' : 'Отправить письмо'}
            </button>
          </div>
        </form>
        
        <div className="auth-footer">
          <div className="auth-separator">
            <span>или</span>
          </div>
          <Link to="/login" className="btn btn-outline w-full">Вернуться к входу</Link>
        </div>
      </div>
    </div>
  );
};

export default ForgotPasswordPage;
