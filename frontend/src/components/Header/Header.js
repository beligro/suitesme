import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import styles from './Header.module.css';

const Header = () => {
  const navigate = useNavigate();
  const { isAuthenticated, logout } = useAuth();

  const handleLogoClick = () => {
    navigate('/');
  };

  const handleLoginClick = () => {
    if (isAuthenticated) {
      logout();
    } else {
      navigate('/login');
    }
  };

  const scrollToSection = (sectionId) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <header className={styles.header}>
      <div className={styles.container}>
        <div className={styles.logo} onClick={handleLogoClick}>
          MNEIDET
        </div>
        
        <nav className={styles.nav}>
          <a 
            className={styles.navItem}
            onClick={() => scrollToSection('advantages')}
          >
            Преимущества
          </a>
          <a 
            className={styles.navItem}
            onClick={() => scrollToSection('about')}
          >
            О сервисе
          </a>
          <a 
            className={styles.navItem}
            onClick={() => scrollToSection('faq')}
          >
            Ответы на вопросы
          </a>
          <a 
            className={styles.navItem}
            onClick={() => scrollToSection('examples')}
          >
            Примеры результатов
          </a>
        </nav>
        
        <button 
          className={styles.loginButton}
          onClick={handleLoginClick}
        >
          {isAuthenticated ? 'Выйти' : 'Войти'}
        </button>
      </div>
    </header>
  );
};

export default Header;
