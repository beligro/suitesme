import React, { useState } from 'react';
import axiosAnotherInstance from './axiosConfig';

const ForgotPasswordPage = () => {
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');

  const handlePasswordReset = async () => {
    try {
      await axiosAnotherInstance.post('/api/v1/auth/forgot_password', { email });
      setMessage('Письмо отправлено! Перейдите по ссылке из письма.');
    } catch (error) {
      console.error('Ошибка при отправке письма для восстановления пароля:', error);
    }
  };

  return (
    <div>
      <h2>Восстановление пароля</h2>
      <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Введите ваш Email" />
      <button onClick={handlePasswordReset}>Отправить письмо</button>
      {message && <p>{message}</p>}
    </div>
  );
};

export default ForgotPasswordPage;
