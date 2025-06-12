import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext.jsx';

/**
 * Компонент для защиты маршрутов, требующих аутентификации
 * Если пользователь не аутентифицирован, происходит редирект на страницу входа
 */
const ProtectedRoute = () => {
  const { isAuthenticated, isLoading } = useAuth();
  
  // Показываем индикатор загрузки, пока проверяем аутентификацию
  if (isLoading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Загрузка...</p>
      </div>
    );
  }
  
  // Если пользователь не аутентифицирован, перенаправляем на страницу входа
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  // Если пользователь аутентифицирован, рендерим дочерние маршруты
  return <Outlet />;
};

export default ProtectedRoute;
