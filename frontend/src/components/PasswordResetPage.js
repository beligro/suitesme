import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import axios from 'axios';

const PasswordResetPage = () => {
  const [password, setPassword] = useState('');
  const [passwordConfirm, setPasswordConfirm] = useState('');
  const [message, setMessage] = useState('');
  const navigate = useNavigate();
  const location = useLocation();

  // Получение токена из параметра запроса
  const query = new URLSearchParams(location.search);
  const resetToken = query.get('token');

  const handlePasswordReset = async () => {
    if (!resetToken) {
      setMessage('Токен не найден.');
      return;
    }

    if (password !== passwordConfirm) {
      setMessage('Пароли не совпадают.');
      return;
    }

    try {
      await axios.post('http://51.250.84.195:8080/api/v1/auth/password/reset', {
        reset_token: resetToken,
        password,
        password_confirm: passwordConfirm,
      });
      setMessage('Пароль успешно изменён.');
      // Вы можете перенаправить пользователя на страницу логина или другую страницу
      setTimeout(() => navigate('/login'), 2000);
    } catch (error) {
      console.error('Ошибка при сбросе пароля:', error);
      setMessage('Ошибка при сбросе пароля.');
    }
  };

  return (
    <div>
      <h2>Сброс пароля</h2>
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Введите новый пароль"
      />
      <input
        type="password"
        value={passwordConfirm}
        onChange={(e) => setPasswordConfirm(e.target.value)}
        placeholder="Подтвердите новый пароль"
      />
      <button onClick={handlePasswordReset}>Отправить</button>
      {message && <p>{message}</p>}
    </div>
  );
};

export default PasswordResetPage;