import React, { useState, useEffect } from 'react';
import axiosInstance from './axiosConfig';
import { useNavigate } from 'react-router-dom';

const RegisterPage = () => {
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    birth_date: '',
    email: '',
    password: '',
    password_confirm: ''
  });
  const navigate = useNavigate();
  const isAuthorized = localStorage.getItem('isAuthorized') === 'true';

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleRegister = async () => {
    try {
      const response = await axiosInstance.post('/api/v1/auth/register', formData);
      console.log('Данные ответа:', response.data);
      localStorage.setItem('userId', response.data.user_id);

      // Передаем email и пароль через `state`
      navigate('/verify_email', {
        state: {
          email: formData.email,
          password: formData.password
        }
      });
    } catch (error) {
      if (error.response.status === 409) {
        navigate('/login');
      }
      console.error('Ошибка регистрации:', error);
    }
  };

  useEffect(() => {
      if (isAuthorized) {
        navigate('/profile');
      }
    }, [isAuthorized, navigate]);

  return (
    <div>
      <h2>Регистрация</h2>
      <input name="first_name" type="text" onChange={handleInputChange} placeholder="Имя" />
      <input name="last_name" type="text" onChange={handleInputChange} placeholder="Фамилия" />
      <input name="birth_date" type="date" onChange={handleInputChange} placeholder="Дата рождения" />
      <input name="email" type="email" onChange={handleInputChange} placeholder="Email" />
      <input name="password" type="password" onChange={handleInputChange} placeholder="Пароль" />
      <input name="password_confirm" type="password" onChange={handleInputChange} placeholder="Подтвердите пароль" />
      <button onClick={handleRegister}>Зарегистрироваться</button>
    </div>
  );
};

export default RegisterPage;
