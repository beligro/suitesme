import React, { useState } from 'react';
import axiosInstance from './axiosConfig';
import { useNavigate, useLocation } from 'react-router-dom';

const VerifyEmailPage = () => {
  const [verificationCode, setVerificationCode] = useState('');
  const navigate = useNavigate();
  const userId = localStorage.getItem('userId');
  const location = useLocation();

  const handleVerify = async () => {
    try {
      if (!userId) throw new Error("User ID is missing");
  
      const response = await axiosInstance.post('/api/v1/auth/verify_email', { verification_code: verificationCode, user_id: userId });
      if (response.status === 200) {
        // Получаем email и пароль из переданных данных
        const { email, password } = location.state;
  
        // Переходим на страницу логина с передачей email и password
        navigate('/login', { state: { email, password } });
      }
    } catch (error) {
      console.error('Ошибка верификации email:', error);
    }
  };

  return (
    <div>
      <h2>Подтверждение Email</h2>
      <input
        type="text"
        value={verificationCode}
        onChange={(e) => setVerificationCode(e.target.value)}
        placeholder="Код подтверждения"
      />
      <button onClick={handleVerify}>Отправить</button>
    </div>
  );
};

export default VerifyEmailPage;
