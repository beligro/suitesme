import React, { useEffect } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import api from '../utils/api.js';
import useForm from '../hooks/useForm.js';
import './AuthPage.css'; // Reuse auth page styles

const VerifyEmailPage = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const userId = localStorage.getItem('userId');

  // Правила валидации для формы верификации
  const validationRules = {
    verification_code: [
      { type: 'required', message: 'Пожалуйста, введите код подтверждения' }
    ]
  };

  // Обработчик отправки формы
  const handleVerifySubmit = async (values) => {
    if (!userId) {
      throw new Error('Идентификатор пользователя не найден. Пожалуйста, зарегистрируйтесь снова.');
    }
    
    try {
      const response = await api.post('/api/v1/auth/verify_email', { 
        verification_code: values.verification_code, 
        user_id: userId 
      });
      
      // Получаем email и пароль из переданных данных
      const { email, password } = location.state || {};
      
      // Переходим на страницу логина с передачей email и password
      navigate('/login', { state: { email, password } });
      
      return response.data;
    } catch (error) {
      console.error('Ошибка верификации email:', error);
      throw new Error(error.response?.data?.message || 'Ошибка верификации. Проверьте код и попробуйте снова.');
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
    { verification_code: '' }, 
    validationRules, 
    handleVerifySubmit
  );

  // Проверяем наличие userId при загрузке компонента
  useEffect(() => {
    if (!userId) {
      // Если userId отсутствует, показываем сообщение об ошибке
      // Ошибка будет отображена через errors._general
    }
  }, [userId]);

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-header">
          <h2 className="auth-title">Подтверждение Email</h2>
          <p className="auth-subtitle">Введите код подтверждения, отправленный на ваш email</p>
        </div>
        
        {errors._general && <div className="alert alert-error">{errors._general}</div>}
        
        <form className="auth-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="verification_code">Код подтверждения</label>
            <input 
              type="text" 
              id="verification_code"
              name="verification_code"
              value={values.verification_code} 
              onChange={handleChange} 
              placeholder="Введите код подтверждения" 
              disabled={isSubmitting}
            />
            {errors.verification_code && <div className="form-error">{errors.verification_code}</div>}
          </div>
          
          <div className="form-actions">
            <button 
              type="submit" 
              className="btn btn-primary btn-lg w-full" 
              disabled={isSubmitting || !userId}
            >
              {isSubmitting ? 'Проверка...' : 'Подтвердить'}
            </button>
          </div>
        </form>
        
        <div className="auth-footer">
          <div className="auth-separator">
            <span>или</span>
          </div>
          <Link to="/register" className="btn btn-outline w-full">Зарегистрироваться заново</Link>
        </div>
      </div>
    </div>
  );
};

export default VerifyEmailPage;
