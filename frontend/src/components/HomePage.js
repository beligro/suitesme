import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchContent } from './axiosConfig';

const HomePage = () => {
  const [content, setContent] = useState({});
  const navigate = useNavigate();
  const isAuthorized = localStorage.getItem('isAuthorized') === 'true';

  useEffect(() => {
    const loadContent = async () => {
      const data = await fetchContent();
      if (data) {
        setContent(data);
      }
    };

    loadContent();
  }, []);

  return (
    <div>
      <h1>{content['hello_text']?.ru_value || 'Добро пожаловать на наш сайт'}</h1>
      <p>Здесь будет текстовая информация...</p>
      <br />
      {isAuthorized ? (
        <button onClick={() => navigate('/profile')}>Профиль</button>
      ) : (
        <>
          <button onClick={() => navigate('/login')}>Войти</button>
          <button onClick={() => navigate('/register')}>Зарегистрироваться</button>
        </>
      )}
    </div>
  );
};

export default HomePage;
