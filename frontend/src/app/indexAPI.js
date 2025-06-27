import axios from 'axios';

const $host = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
});

const $authHost = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
});

const authInterceptor = (config) => {
    const token = localStorage.getItem("access_token");
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
};

$authHost.interceptors.request.use(authInterceptor);

$authHost.interceptors.response.use(
    (response) => response,
    async (error) => {
        const originalRequest = error.config;

        if ((error.response?.status === 401 || error.response?.status === 403) && !originalRequest._retry) {
            originalRequest._retry = true;

            const refreshToken = localStorage.getItem("refresh_token");

            try {
                const response = await axios.post(
                    `${import.meta.env.VITE_API_URL}/auth/refresh`,
                    { refresh_token: refreshToken }
                );

                const { access_token, refresh_token } = response.data;

                localStorage.setItem("access_token", access_token);
                localStorage.setItem("refresh_token", refresh_token);

                originalRequest.headers.Authorization = `Bearer ${access_token}`;

                return $authHost(originalRequest);
            } catch (refreshError) {
                console.error("Ошибка обновления токена:", refreshError);
                localStorage.removeItem("access_token");
                localStorage.removeItem("refresh_token");
                // window.location.href = "/login";

                return Promise.reject(refreshError);
            }
        }

        return Promise.reject(error);
    }
);

export { $host, $authHost };