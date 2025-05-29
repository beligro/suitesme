import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchContent } from '../utils/api';
import { useAuth } from '../contexts/AuthContext';
import styles from './HomePage.module.css';

// Import images
import heroPhoto from '../assets/images/hero-photo.jpg';
import decorativeElement1 from '../assets/images/decorative-element-1.jpg';
import decorativeElement2 from '../assets/images/decorative-element-2.jpg';

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

  const handleGetStarted = () => {
    if (isAuthenticated) {
      navigate('/profile');
    } else {
      navigate('/register');
    }
  };

  const handleLogin = () => {
    navigate('/login');
  };

  if (isLoading) {
    return (
      <div className={styles.homePage}>
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Загрузка контента...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.homePage}>
        <div className="error-container">
          <p className="error-message">{error}</p>
          <button 
            className="btn btn-primary" 
            onClick={() => window.location.reload()}
          >
            Попробовать снова
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.homePage}>
      {/* Navigation Header */}
      <header className={styles.navigationHeader}>
        <div className={styles.logo} onClick={() => navigate('/')}>
          <span className={styles.logoMain}>MNE</span>
          <span className={styles.logoSub}>IDET</span>
        </div>
        
        <nav className={styles.navigation}>
          <ul className={styles.navMenu}>
            <li className={styles.navItem}>Преимущества</li>
            <li className={styles.navItem}>О сервисе</li>
            <li className={styles.navItem}>Ответы на вопросы</li>
            <li className={styles.navItem}>Примеры результатов</li>
          </ul>
          
          {!isAuthenticated && (
            <button className={styles.loginButton} onClick={handleLogin}>
              Войти
            </button>
          )}
        </nav>
      </header>

      {/* Hero Section */}
      <section className={styles.heroSection}>
        {/* Background Images */}
        <img 
          src={heroPhoto} 
          alt="Hero" 
          className={styles.heroPhoto}
        />
        <img 
          src={decorativeElement1} 
          alt="Decorative" 
          className={styles.decorativeElement1}
        />
        <img 
          src={decorativeElement2} 
          alt="Decorative" 
          className={styles.decorativeElement2}
        />
        
        {/* Gradient Overlays */}
        <div className={styles.gradientLeft}></div>
        <div className={styles.gradientRight}></div>
        
        {/* Blur Effects */}
        <div className={styles.blurCircle1}></div>
        <div className={styles.blurCircle2}></div>
        
        {/* Hero Content */}
        <div className={styles.heroContent}>
          <h1 className={styles.heroTitle}>
            Узнай,<br />
            что тебе<br />
            действи-тельно<br />
            идёт
          </h1>
          
          <div className={styles.heroDescription}>
            <div className={styles.heroDescriptionIcon1}></div>
            <div className={styles.heroDescriptionIcon2}></div>
            <p className={styles.heroDescriptionText}>
              Наш искусственный интеллект анализирует черты лица и определяет типаж по системе<br />
              MNE IDET
            </p>
          </div>
          
          <button className={styles.heroButton} onClick={handleGetStarted}>
            {isAuthenticated ? 'Мой профиль' : 'Узнать свой типаж'}
          </button>
        </div>
      </section>
    </div>
  );
};

export default HomePage;
