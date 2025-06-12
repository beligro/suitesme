import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { publicApi } from '../utils/api.js';
import useForm from '../hooks/useForm.js';
import './AuthPage.css'; // Reuse auth page styles

const PasswordResetPage = () => {
  const [success, setSuccess] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  // Получение токена из параметра запроса
  const query = new URLSearchParams(location.search);
  const resetToken = query.get('token');

  // Правила валидации для формы сброса пароля
  const validationRules = {
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
  const handlePasswordResetSubmit = async (values) => {
    if (!resetToken) {
      throw new Error('Токен сброса пароля не найден. Пожалуйста, проверьте ссылку или запросите новую.');
    }

    try {
      await publicApi.post('/api/v1/auth/password/reset', {
        reset_token: resetToken,
        password: values.password,
        password_confirm: values.password_confirm,
      });
      
      setSuccess(true);
      
      // Перенаправляем пользователя на страницу логина через 3 секунды
      setTimeout(() => navigate('/login'), 3000);
      
      return true;
    } catch (error) {
      console.error('Ошибка при сбросе пароля:', error);
      throw new Error(error.response?.data?.message || 'Ошибка при сбросе пароля. Пожалуйста, попробуйте снова.');
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
    { password: '', password_confirm: '' }, 
    validationRules, 
    handlePasswordResetSubmit
  );

  // Проверяем наличие токена при загрузке компонента
  useEffect(() => {
    if (!resetToken) {
      // Если токен отсутствует, показываем сообщение об ошибке
      // Ошибка будет отображена через errors._general
    }
  }, [resetToken]);

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-header">
          <h2 className="auth-title">Сброс пароля</h2>
          <p className="auth-subtitle">Введите новый пароль для вашего аккаунта</p>
        </div>
        
        {errors._general && <div className="alert alert-error">{errors._general}</div>}
        {success && (
          <div className="alert alert-success">
            Пароль успешно изменён. Вы будете перенаправлены на страницу входа...
          </div>
        )}
        
        {!success && (
          <form className="auth-form" onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="password">Новый пароль</label>
              <input 
                type="password" 
                id="password"
                name="password"
                value={values.password} 
                onChange={handleChange} 
                placeholder="Введите новый пароль" 
                disabled={isSubmitting}
              />
              {errors.password && <div className="form-error">{errors.password}</div>}
            </div>
            
            <div className="form-group">
              <label htmlFor="password_confirm">Подтверждение пароля</label>
              <input 
                type="password" 
                id="password_confirm"
                name="password_confirm"
                value={values.password_confirm} 
                onChange={handleChange} 
                placeholder="Подтвердите новый пароль" 
                disabled={isSubmitting}
              />
              {errors.password_confirm && <div className="form-error">{errors.password_confirm}</div>}
            </div>
            
            <div className="form-actions">
              <button 
                type="submit" 
                className="btn btn-primary btn-lg w-full" 
                disabled={isSubmitting || !resetToken}
              >
                {isSubmitting ? 'Сохранение...' : 'Сохранить новый пароль'}
              </button>
            </div>
          </form>
        )}
        
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

export default PasswordResetPage;
