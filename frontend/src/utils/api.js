import axios from 'axios';
import Cookies from 'js-cookie';

// Константы для API
const API_BASE_URL = import.meta.env.API_URL || 'http://51.250.84.195:8080';
const API_TIMEOUT = 15000; // 15 секунд

// Создаем основной экземпляр axios
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Экземпляр для запросов, не требующих авторизации
export const publicApi = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Переменная для хранения функции навигации
let navigationCallback = null;

// Функция для установки callback навигации
export const setNavigationCallback = (callback) => {
  navigationCallback = callback;
};

// Перехватчик запросов для добавления токена авторизации
api.interceptors.request.use(
  (config) => {
    try {
      const accessToken = Cookies.get('access_token');
      if (accessToken) {
        config.headers.Authorization = `Bearer ${accessToken}`;
      }
      return config;
    } catch (error) {
      console.error('Ошибка в перехватчике запросов:', error);
      return config;
    }
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Перехватчик ответов для обработки ошибок и обновления токенов
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    // Проверяем, что ошибка связана с ответом сервера
    if (!error.response) {
      console.error('Ошибка сети или сервер недоступен:', error.message);
      return Promise.reject(error);
    }

    // Обрабатываем ошибку 401 (Unauthorized)
    if (error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = Cookies.get('refresh_token');
        
        // Если нет refresh токена, перенаправляем на страницу входа
        if (!refreshToken) {
          if (navigationCallback) {
            localStorage.setItem('isAuthorized', 'false');
            navigationCallback('/login');
          }
          return Promise.reject(error);
        }
        
        // Пытаемся обновить токены
        const response = await publicApi.post('/api/v1/auth/refresh', { 
          refresh_token: refreshToken 
        });
        
        // Получаем новые токены
        const { access_token, refresh_token } = response.data;
        
        // Сохраняем новые токены
        Cookies.set('access_token', access_token, { 
          secure: window.location.protocol === 'https:',
          sameSite: 'strict'
        });
        Cookies.set('refresh_token', refresh_token, { 
          secure: window.location.protocol === 'https:',
          sameSite: 'strict'
        });
        
        // Обновляем заголовок для текущего запроса
        originalRequest.headers.Authorization = `Bearer ${access_token}`;
        
        // Повторяем оригинальный запрос с новым токеном
        return api(originalRequest);
      } catch (refreshError) {
        console.error('Ошибка при обновлении токена:', refreshError);
        
        // Очищаем данные авторизации и перенаправляем на страницу входа
        Cookies.remove('access_token');
        Cookies.remove('refresh_token');
        localStorage.setItem('isAuthorized', 'false');
        
        if (navigationCallback) {
          navigationCallback('/login');
        }
        
        return Promise.reject(refreshError);
      }
    }
    
    // Обрабатываем другие ошибки
    return Promise.reject(error);
  }
);

// Функция для получения контента
export const fetchContent = async () => {
  try {
    const response = await publicApi.get('/api/v1/content/list');
    return response.data;
  } catch (error) {
    console.error('Ошибка при получении контента:', error);
    return null;
  }
};

// Экспортируем API по умолчанию
export default api;
