import {useEffect, useState} from "react";
import {useLocation, useNavigate} from "react-router-dom";
import {useAuth} from "../../../contexts/AuthContext.jsx";
import api from "../../../utils/api.js";
import useForm from "../../../hooks/useForm.js";

const Login = () => {
    const [showPassword, setShowPassword] = useState(false);
    const nav = useNavigate()


    const location = useLocation();
    const { isAuthenticated, login } = useAuth();

    const validationRules = {
        email: [
            { type: 'required', message: 'Email обязателен' },
            { type: 'email', message: 'Некорректный формат email' }
        ],
        password: [
            { type: 'required', message: 'Пароль обязателен' }
        ]
    };

    // Обработчик отправки формы
    const handleLoginSubmit = async (values) => {
        try {
            const response = await api.post('/api/v1/auth/login', {
                email: values.email,
                password: values.password
            });

            const { access_token, refresh_token } = response.data;

            // Используем функцию login из контекста аутентификации
            login(access_token, refresh_token);

            // Перенаправляем на страницу профиля
            nav('/profile');

            return response.data;
        } catch (error) {
            console.error('Ошибка авторизации:', error);
            throw new Error(error.response?.data?.message || 'Ошибка авторизации. Проверьте введенные данные.');
        }
    };

    const {
        values,
        errors,
        isSubmitting,
        handleChange,
        handleSubmit,
        setAllValues
    } = useForm(
        { email: '', password: '' },
        validationRules,
        handleLoginSubmit
    );

    // Если пользователь уже авторизован, перенаправляем на страницу профиля
    useEffect(() => {
        if (isAuthenticated) {
            nav('/profile');
        }
    }, [isAuthenticated, nav]);

    // Если есть данные в location.state, используем их для автоматического входа
    useEffect(() => {
        if (location.state) {
            const { email, password } = location.state;
            if (email && password) {
                setAllValues({ email, password });
                handleSubmit();
            }
        }
    }, [location.state, setAllValues, handleSubmit]);


    return (
        <form onSubmit={handleSubmit} className="w-full min-h-screen flex justify-center items-center">
            <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                <div className="w-full h-full flex flex-col justify-between gap-10">
                    <div className="w-full flex flex-col gap-10 relative">
                        <div className="md:hidden flex flex-row items-center justify-between w-full">
                            <img src="/photos/Auth/Back.svg" alt="" className="cursor-pointer" onClick={() => {nav(-1)}}/>
                            <img src="/photos/Auth/Star.svg" alt="" />
                        </div>

                        <img className="md:block hidden absolute -left-20 cursor-pointer" src="/photos/Auth/Back.svg" alt="" onClick={() => {nav(-1)}}/>

                        <p className="font-unbounded text-left md:uppercase font-medium text-[20px]">войти</p>
                        <div className="w-full flex flex-col gap-2">
                            <div className="w-full flex flex-col gap-1">
                                <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">email</p>
                                <input
                                    type="email"
                                    name="email"
                                    value={values.email}
                                    onChange={handleChange}
                                    className="border-b px-3 py-2 rounded-2xl"
                                />
                                {errors.email && <p className="text-red-500 text-sm">{errors.email}</p>}
                            </div>

                            {/* Пароль */}
                            <div className="w-full flex flex-col gap-1">
                                <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">пароль</p>
                                <div className="relative">
                                    <input
                                        type={showPassword ? "text" : "password"}
                                        name="password"
                                        value={values.password}
                                        onChange={handleChange}
                                        className="border-b px-3 py-2 rounded-2xl w-full pr-10"
                                    />
                                    <button
                                        type="button"
                                        onClick={() => setShowPassword(!showPassword)}
                                        className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-500"
                                    >
                                        {showPassword ? (
                                            <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-1.274 4.057-5.065 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                            </svg>
                                        ) : (
                                            <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.477 0-8.268-2.943-9.542-7a10.05 10.05 0 012.266-3.592m2.732-1.846A9.96 9.96 0 0112 5c4.477 0 8.268 2.943 9.542 7a9.96 9.96 0 01-1.065 2.1M15 12a3 3 0 11-6 0 3 3 0 016 0zM3 3l18 18" />
                                            </svg>
                                        )}
                                    </button>
                                </div>
                                {errors.password && <p className="text-red-500 text-sm">{errors.password}</p>}
                            </div>
                        </div>
                        <div className="w-full flex flex-row justify-end gap-3">
                            <p className="uppercase font-montserrat text-right font-thin cursor-pointer text-[14px]" onClick={() => {nav("/forgotpassword")}}>забыли пароль?</p>
                        </div>
                    </div>
                    <div className="w-full flex flex-col gap-10">
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className="w-full bg-[#1B3C4D] py-5 rounded-2xl disabled:opacity-50"
                        >
                            <p className="uppercase font-unbounded font-light text-white">войти</p>
                        </button>
                        <div className="text-center uppercase font-montserrat text-[#8296A6] text-[12px]">ЕЩЕ НЕТ аккаунтА? <span className="cursor-pointer text-black" onClick={() => {nav("/register")}}> ЗАРЕГИСТРИРОВАТЬСЯ</span> </div>
                        <div className="w-full flex justify-center">
                            <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt=""/>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    );
};

export default Login;