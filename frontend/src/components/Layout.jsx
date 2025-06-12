import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext.jsx';
import './Layout.css';

const Layout = ({ children }) => {
  const navigate = useNavigate();
  const { isAuthenticated, logout } = useAuth();

  const handleLogout = () => {
    logout();
  };

  return (
    <div className="layout">
      <header className="header">
        <div className="container">
          <div className="header-content">
            <div className="logo" onClick={() => navigate('/')}>
              <span className="logo-text">SuitesMe</span>
            </div>
            <nav className="nav">
              <ul className="nav-list">
                <li className="nav-item">
                  <Link to="/" className="nav-link">Главная</Link>
                </li>
                {isAuthenticated ? (
                  <>
                    <li className="nav-item">
                      <Link to="/profile" className="nav-link">Профиль</Link>
                    </li>
                    <li className="nav-item">
                      <button 
                        className="btn btn-outline nav-button"
                        onClick={handleLogout}
                      >
                        Выйти
                      </button>
                    </li>
                  </>
                ) : (
                  <>
                    <li className="nav-item">
                      <Link to="/login" className="nav-link">Войти</Link>
                    </li>
                    <li className="nav-item">
                      <Link to="/register" className="btn btn-primary nav-button">Регистрация</Link>
                    </li>
                  </>
                )}
              </ul>
            </nav>
          </div>
        </div>
      </header>

      <main className="main">
        <div className="container">
          {children}
        </div>
      </main>

      <footer className="footer">
        <div className="container">
          <div className="footer-content">
            <div className="footer-logo">
              <span className="logo-text">SuitesMe</span>
              <p className="footer-tagline">Найдите свой стиль с нами</p>
            </div>
            <div className="footer-links">
              <div className="footer-section">
                <h4 className="footer-heading">Навигация</h4>
                <ul className="footer-nav">
                  <li><Link to="/" className="footer-link">Главная</Link></li>
                  {isAuthenticated ? (
                    <li><Link to="/profile" className="footer-link">Профиль</Link></li>
                  ) : (
                    <>
                      <li><Link to="/login" className="footer-link">Войти</Link></li>
                      <li><Link to="/register" className="footer-link">Регистрация</Link></li>
                    </>
                  )}
                </ul>
              </div>
              <div className="footer-section">
                <h4 className="footer-heading">Поддержка</h4>
                <ul className="footer-nav">
                  <li><a href="#" className="footer-link">Помощь</a></li>
                  <li><a href="#" className="footer-link">Контакты</a></li>
                  <li><a href="#" className="footer-link">FAQ</a></li>
                </ul>
              </div>
              <div className="footer-section">
                <h4 className="footer-heading">Правовая информация</h4>
                <ul className="footer-nav">
                  <li><a href="#" className="footer-link">Условия использования</a></li>
                  <li><a href="#" className="footer-link">Политика конфиденциальности</a></li>
                </ul>
              </div>
            </div>
          </div>
          <div className="footer-bottom">
            <p className="copyright">© {new Date().getFullYear()} SuitesMe. Все права защищены.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Layout;
