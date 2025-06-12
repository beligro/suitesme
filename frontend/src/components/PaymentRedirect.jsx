import React, { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext.jsx';
import api from '../utils/api.js';
import './PaymentRedirect.css';

/**
 * Компонент для обработки перенаправления после платежа
 * Показывает индикатор загрузки и перенаправляет на страницу профиля
 * с информацией о статусе платежа
 */
const PaymentRedirect = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { isAuthenticated } = useAuth();
  const [redirectMessage, setRedirectMessage] = useState('Обработка платежа, пожалуйста, подождите...');
  
  useEffect(() => {
    // Проверяем, авторизован ли пользователь
    if (!isAuthenticated) {
      navigate('/login', { replace: true });
      return;
    }
    
    // Получаем query-параметр status
    const params = new URLSearchParams(location.search);
    const status = params.get('status');
    
    // Устанавливаем сообщение в зависимости от статуса
    if (status === 'ok') {
      setRedirectMessage('Платеж успешно обработан. Перенаправление...');
      
      // Отправляем уведомление на бэкенд
      api.post('/api/v1/payment/notify')
        .then(() => {
          console.log('Уведомление о платеже успешно отправлено');
        })
        .catch(error => {
          console.error('Ошибка при отправке уведомления о платеже:', error);
        });
    } else if (status === 'fail') {
      setRedirectMessage('Возникла проблема с платежом. Перенаправление...');
    }
    
    // Небольшая задержка для лучшего UX
    const redirectTimer = setTimeout(() => {
      // Перенаправляем на страницу профиля с параметром состояния
      navigate('/profile', { 
        state: { 
          fromPayment: true, 
          paymentStatus: status 
        },
        replace: true // Заменяем текущую запись в истории браузера
      });
    }, 2000);
    
    // Очистка таймера при размонтировании компонента
    return () => clearTimeout(redirectTimer);
  }, [navigate, location, isAuthenticated]);
  
  return (
    <div className="payment-redirect-container">
      <div className="payment-redirect-card">
        <div className="loading-spinner"></div>
        <p className="redirect-message">{redirectMessage}</p>
      </div>
    </div>
  );
};

export default PaymentRedirect;
