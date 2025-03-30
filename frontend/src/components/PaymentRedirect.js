// PaymentRedirect.js
import React, { useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

const PaymentRedirect = () => {
  const navigate = useNavigate();
  const location = useLocation();
  
  useEffect(() => {
    // Получаем query-параметр status
    const params = new URLSearchParams(location.search);
    const status = params.get('status');
    
    // Перенаправляем на страницу профиля с параметром состояния
    navigate('/profile', { 
      state: { 
        fromPayment: true, 
        paymentStatus: status 
      } 
    });
  }, [navigate, location]);
  
  // Можно показать спиннер загрузки, пока идет перенаправление
  return (
    <div className="payment-redirect-container">
      <div className="loading-spinner"></div>
      <p>Перенаправление...</p>
    </div>
  );
};

export default PaymentRedirect;
