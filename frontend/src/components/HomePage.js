import React from 'react';
import { useNavigate } from 'react-router-dom';

const HomePage = () => {
  const navigate = useNavigate();
  const isAuthorized = localStorage.getItem('isAuthorized') === 'true';

  return (
    <div>
      <h1>Добро пожаловать на наш сайт</h1>
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
