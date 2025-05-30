import React, { useState } from 'react';
import styles from './Header.module.css';

const Header = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  return (
    <header className={styles.header}>
      <div className={styles.container}>
        <div className={styles.logo}>
          <span className={styles.logoText}>MNEIDET</span>
        </div>
        
        <button 
          className={styles.menuButton}
          onClick={toggleMenu}
          aria-label="Открыть меню"
        >
          <span className={styles.menuLine}></span>
          <span className={styles.menuLine}></span>
          <span className={styles.menuLine}></span>
        </button>
      </div>

      {/* Mobile Menu Overlay */}
      {isMenuOpen && (
        <div className={styles.mobileMenu}>
          <div className={styles.mobileMenuContent}>
            <nav className={styles.navigation}>
              <a href="#benefits" className={styles.navLink}>Преимущества</a>
              <a href="#about" className={styles.navLink}>О сервисе</a>
              <a href="#faq" className={styles.navLink}>Ответы на вопросы</a>
              <a href="#results" className={styles.navLink}>Результаты</a>
            </nav>
            <button className={styles.loginButton}>
              Войти
            </button>
          </div>
        </div>
      )}
    </header>
  );
};

export default Header;
