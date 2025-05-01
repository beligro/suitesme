import React, { Component } from 'react';

/**
 * Компонент для обработки ошибок в дочерних компонентах
 * Предотвращает падение всего приложения при ошибке в отдельном компоненте
 */
class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { 
      hasError: false,
      error: null,
      errorInfo: null
    };
  }

  // Обновляем состояние, если произошла ошибка
  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  // Логируем информацию об ошибке
  componentDidCatch(error, errorInfo) {
    this.setState({
      error: error,
      errorInfo: errorInfo
    });
    
    // Здесь можно добавить логирование ошибок в сервис аналитики
    console.error('Ошибка в компоненте:', error, errorInfo);
  }

  // Сбрасываем состояние ошибки
  resetError = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null
    });
  }

  render() {
    // Если есть ошибка, показываем запасной UI
    if (this.state.hasError) {
      // Можно настроить разные варианты отображения в зависимости от типа ошибки
      return (
        <div className="error-boundary">
          <div className="error-container">
            <h2>Что-то пошло не так</h2>
            <p>Произошла ошибка при отображении этого компонента.</p>
            
            {/* Кнопка для повторной попытки */}
            <button 
              className="btn btn-primary" 
              onClick={this.resetError}
            >
              Попробовать снова
            </button>
            
            {/* Отображаем детали ошибки только в режиме разработки */}
            {process.env.NODE_ENV === 'development' && (
              <details className="error-details">
                <summary>Детали ошибки</summary>
                <p>{this.state.error && this.state.error.toString()}</p>
                <div>
                  {this.state.errorInfo && this.state.errorInfo.componentStack}
                </div>
              </details>
            )}
          </div>
        </div>
      );
    }

    // Если ошибки нет, рендерим дочерние компоненты
    return this.props.children;
  }
}

export default ErrorBoundary;
