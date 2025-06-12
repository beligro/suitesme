import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchContent } from '../utils/api.js';
import { useAuth } from '../contexts/AuthContext.jsx';
import './HomePage.css';

const HomePage = () => {
  const [content, setContent] = useState({});
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();

  useEffect(() => {
    const loadContent = async () => {
      setIsLoading(true);
      try {
        const data = await fetchContent();
        if (data) {
          setContent(data);
        }
        setError(null);
      } catch (err) {
        console.error('Ошибка при загрузке контента:', err);
        setError('Не удалось загрузить контент. Пожалуйста, попробуйте позже.');
      } finally {
        setIsLoading(false);
      }
    };

    loadContent();
  }, []);

  return (
    <div className="home-page">
      {isLoading ? (
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Загрузка контента...</p>
        </div>
      ) : error ? (
        <div className="error-container">
          <p className="error-message">{error}</p>
          <button 
            className="btn btn-primary" 
            onClick={() => window.location.reload()}
          >
            Попробовать снова
          </button>
        </div>
      ) : (
        <>
          <section className="hero">
            <div className="hero-content">
              <h1 className='text-xl  text-red-700 font-normal'>тест таилвинда</h1>
              <h1 className="hero-title">{content['hello_text']?.ru_value || 'Добро пожаловать в SuitesMe'}</h1>
              <p className="hero-subtitle">Откройте свой уникальный стиль с помощью нашего сервиса</p>
              
              <div className="hero-buttons">
                {isAuthenticated ? (
                  <button className="btn btn-primary btn-lg" onClick={() => navigate('/profile')}>
                    Мой профиль
                  </button>
                ) : (
                  <>
                    <button className="btn btn-primary btn-lg" onClick={() => navigate('/register')}>
                      Начать сейчас
                    </button>
                    <button className="btn btn-outline btn-lg ml-md" onClick={() => navigate('/login')}>
                      Войти
                    </button>
                  </>
                )}
              </div>
            </div>
          </section>

          <section className="features">
            <h2 className="section-title">Как это работает</h2>
            <div className="feature-grid">
              <div className="feature-card">
                <div className="feature-icon">1</div>
                <h3 className="feature-title">Регистрация</h3>
                <p className="feature-description">Создайте аккаунт и заполните информацию о себе</p>
              </div>
              <div className="feature-card">
                <div className="feature-icon">2</div>
                <h3 className="feature-title">Загрузка фото</h3>
                <p className="feature-description">Загрузите свою фотографию для анализа</p>
              </div>
              <div className="feature-card">
                <div className="feature-icon">3</div>
                <h3 className="feature-title">Анализ</h3>
                <p className="feature-description">Наша система определит ваш типаж и подберет рекомендации</p>
              </div>
              <div className="feature-card">
                <div className="feature-icon">4</div>
                <h3 className="feature-title">Результат</h3>
                <p className="feature-description">Получите персональные рекомендации по стилю</p>
              </div>
            </div>
          </section>

          <section className="cta">
            <div className="cta-content">
              <h2 className="cta-title">Готовы узнать свой стиль?</h2>
              <p className="cta-description">Присоединяйтесь к тысячам людей, которые уже нашли свой уникальный стиль с SuitesMe</p>
              {!isAuthenticated && (
                <button className="btn btn-primary btn-lg" onClick={() => navigate('/register')}>
                  Зарегистрироваться
                </button>
              )}
            </div>
          </section>
        </>
      )}
    </div>
  );
};

export default HomePage;
