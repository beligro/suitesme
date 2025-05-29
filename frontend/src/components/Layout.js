import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import Header from './Header';
import './Layout.css';

const Layout = ({ children }) => {
  const { isAuthenticated } = useAuth();

  return (
    <div className="layout">
      <Header />

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
