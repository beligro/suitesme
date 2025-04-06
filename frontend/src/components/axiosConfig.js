import axios from 'axios';
import Cookies from 'js-cookie';

let navigationCallback = null;

export const setNavigationCallback = (callback) => {
  navigationCallback = callback;
};

const axiosInstance = axios.create({
  baseURL: 'http://51.250.84.195:8080'
});

const axiosAnotherInstance = axios.create({
  baseURL: 'http://51.250.84.195:8080'
});

axiosInstance.interceptors.request.use(
  (config) => {
    const accessToken = Cookies.get('access_token');
    if (accessToken) {
      config.headers['Authorization'] = `Bearer ${accessToken}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

axiosInstance.interceptors.response.use(
  (response) => {return response;},
  async (error) => {
    const originalRequest = error.config;

    if (error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      const refreshToken = Cookies.get('refresh_token');

      if (!refreshToken && navigationCallback) {
        localStorage.setItem('isAuthorized', 'false');
        navigationCallback('/login');
        return Promise.reject(error);
      }

      try {
        const response = await axiosAnotherInstance.post('/api/v1/auth/refresh', { refresh_token: refreshToken });

        // Обновляем токены
        const { access_token, refresh_token } = response.data;
        Cookies.set('access_token', access_token);
        Cookies.set('refresh_token', refresh_token);

        // Повторяем изначальный запрос с новым токеном
        axios.defaults.headers.common['Authorization'] = `Bearer ${access_token}`;
        return axiosInstance(originalRequest);
      } catch (refreshError) {
        localStorage.setItem('isAuthorized', 'false');
        navigationCallback('/login');
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export const fetchContent = async () => {
  try {
    const response = await axiosAnotherInstance.get('/api/v1/content/list');
    const data = response.data;
    return data;
  } catch (error) {
    console.error('Ошибка при получении контента:', error);
    return null;
  }
};

export default axiosInstance;
