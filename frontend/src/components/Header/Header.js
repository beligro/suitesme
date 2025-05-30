import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import styles from './Header.module.css';

const Header = () => {
  const navigate = useNavigate();
  const { isAuthenticated, logout } = useAuth();

  const handleLogout = () => {
    logout();
  };

  return (
    <header className={styles.header}>
      <div className={styles.container}>
        <div className={styles.headerContent}>
          {/* Логотип MNEIDET */}
          <div className={styles.logo} onClick={() => navigate('/')}>
            <span className={styles.logoMne}>MNE</span>
            <span className={styles.logoIdet}>IDET</span>
          </div>

          {/* Навигационное меню */}
          <nav className={styles.nav}>
            <ul className={styles.navList}>
              <li className={styles.navItem}>
                <Link to="#advantages" className={styles.navLink}>Преимущества</Link>
              </li>
              <li className={styles.navItem}>
                <Link to="#about" className={styles.navLink}>О сервисе</Link>
              </li>
              <li className={styles.navItem}>
                <Link to="#faq" className={styles.navLink}>Ответы на вопросы</Link>
              </li>
              <li className={styles.navItem}>
                <Link to="#examples" className={styles.navLink}>Примеры результатов</Link>
              </li>
            </ul>
          </nav>

          {/* Кнопка входа */}
          <div className={styles.authSection}>
            {isAuthenticated ? (
              <div className={styles.userMenu}>
                <Link to="/profile" className={styles.profileLink}>Профиль</Link>
                <button 
                  className={styles.logoutButton}
                  onClick={handleLogout}
                >
                  Выйти
                </button>
              </div>
            ) : (
              <button 
                className={styles.loginButton}
                onClick={() => navigate('/login')}
              >
                Войти
              </button>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
