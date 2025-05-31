import React, { useState } from 'react';
import styles from './Header.module.css';

const Header = () => {
  const [menuOpen, setMenuOpen] = useState(false);

  const toggleMenu = () => {
    setMenuOpen(!menuOpen);
  };

  return (
    <header className={styles.header}>
      <div className={styles.container}>
        <div className={styles.logo}>MNEIDET</div>
        <div className={styles.menuIcon} onClick={toggleMenu}>
          <span></span>
          <span></span>
          <span></span>
        </div>
        
        {menuOpen && (
          <nav className={styles.mobileMenu}>
            <div className={styles.closeIcon} onClick={toggleMenu}>
              <span></span>
              <span></span>
            </div>
            <ul className={styles.menuItems}>
              <li><a href="#benefits">Преимущества</a></li>
              <li><a href="#about">О сервисе</a></li>
              <li><a href="#faq">Ответы на вопросы</a></li>
              <li><a href="#results">Результаты</a></li>
            </ul>
            <button className={styles.loginButton}>Войти</button>
          </nav>
        )}
      </div>
    </header>
  );
};

export default Header;
