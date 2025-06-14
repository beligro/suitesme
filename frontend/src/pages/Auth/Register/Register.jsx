import {useEffect, useState} from "react";
import {useNavigate} from "react-router-dom";
import api from "../../../utils/api.js";
import {useAuth} from "../../../contexts/AuthContext.jsx";
import useForm from "../../../hooks/useForm.js";

const Register = () => {
    const [showPassword, setShowPassword] = useState(false);
    const [showRepeatPassword, setShowRepeatPassword] = useState(false);
    const [isActive, setIsActive] = useState(false);
    const nav = useNavigate()

    const { isAuthenticated } = useAuth();

    // Начальные значения формы
    const initialValues = {
        first_name: '',
        last_name: '',
        birth_date: '',
        email: '',
        password: '',
        password_confirm: ''
    };

    // Правила валидации для формы регистрации
    const validationRules = {
        first_name: [
            { type: 'required', message: 'Имя обязательно' }
        ],
        last_name: [
            { type: 'required', message: 'Фамилия обязательна' }
        ],
        birth_date: [
            { type: 'required', message: 'Дата рождения обязательна' },
            { type: 'date', message: 'Некорректная дата рождения' }
        ],
        email: [
            { type: 'required', message: 'Email обязателен' },
            { type: 'email', message: 'Некорректный формат email' }
        ],
        password: [
            { type: 'required', message: 'Пароль обязателен' },
            { type: 'minLength', value: 6, message: 'Пароль должен содержать минимум 6 символов' }
        ],
        password_confirm: [
            { type: 'required', message: 'Подтверждение пароля обязательно' },
            { type: 'match', field: 'password', message: 'Пароли не совпадают' }
        ]
    };

    // Обработчик отправки формы
    const handleRegisterSubmit = async (values) => {
        try {
            const response = await api.post('/api/v1/auth/register', values);

            // Сохраняем ID пользователя для верификации email
            localStorage.setItem('userId', response.data.user_id);

            // Перенаправляем на страницу верификации email с передачей данных
            nav('/verify_email', {
                state: {
                    email: values.email,
                    password: values.password
                }
            });

            return response.data;
        } catch (error) {
            console.error('Ошибка регистрации:', error);

            // Обрабатываем ошибку конфликта (пользователь уже существует)
            if (error.response?.status === 409) {
                throw new Error('Пользователь с таким email уже существует');
            }

            throw new Error(error.response?.data?.message || 'Ошибка при регистрации. Пожалуйста, попробуйте снова.');
        }
    };

    // Инициализируем хук формы
    const {
        values,
        errors,
        isSubmitting,
        handleChange,
        handleSubmit
    } = useForm(
        initialValues,
        validationRules,
        handleRegisterSubmit
    );

    // Если пользователь уже авторизован, перенаправляем на страницу профиля
    useEffect(() => {
        if (isAuthenticated) {
            nav('/profile');
        }
    }, [isAuthenticated, nav]);


    return (
        <form className="w-full min-h-screen flex justify-center items-center" onSubmit={handleSubmit}>
            <div className="w-[400px] md:h-[780px] h-[800px] sm:p-0 p-5">
                <div className="w-full flex flex-col gap-10 relative">
                    <div className="md:hidden flex flex-row items-center justify-between w-full">
                        <img src="/photos/Auth/Back.svg" alt="" className="cursor-pointer" onClick={() => {nav(-1)}}/>
                        <img src="/photos/Auth/Star.svg" alt="" />
                    </div>
                    <img className="md:block hidden absolute -left-20 cursor-pointer" src="/photos/Auth/Back.svg" alt="" onClick={() => {nav(-1)}}/>
                    <p className="font-unbounded text-left sm:uppercase font-medium text-[20px]">создать аккаунт</p>
                    <div className="w-full flex flex-col gap-2">
                        {[
                            { label: "имя", name: "first_name" },
                            { label: "фамилия", name: "last_name" },
                            { label: "дата рождения", name: "birth_date", type: "date" },
                            { label: "email", name: "email", type: "email" }
                        ].map(({ label, name, type = "text" }) => (
                            <div key={name} className="w-full flex flex-col gap-1">
                                <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">{label}</p>
                                <input
                                    type={type}
                                    name={name}
                                    value={values[name]}
                                    onChange={handleChange}
                                    className="border-b px-3 py-2 rounded-2xl"
                                />
                                {errors[name] && <p className="text-red-500 text-xs">{errors[name]}</p>}
                            </div>
                        ))}

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
                            {errors.password && <p className="text-red-500 text-xs">{errors.password}</p>}
                        </div>

                        <div className="w-full flex flex-col gap-1">
                            <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">подтвердите пароль</p>
                            <div className="relative">
                                <input
                                    type={showRepeatPassword ? "text" : "password"}
                                    name="password_confirm"
                                    value={values.password_confirm}
                                    onChange={handleChange}
                                    className="border-b px-3 py-2 rounded-2xl w-full pr-10"
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowRepeatPassword(!showRepeatPassword)}
                                    className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-500"
                                >
                                    {showRepeatPassword ? (
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
                            {errors.password_confirm && <p className="text-red-500 text-xs">{errors.password_confirm}</p>}
                        </div>

                    </div>
                    <div className="w-full flex flex-row justify-start items-start gap-3">
                        <img className={`${isActive ? "hidden": "block"} w-5 cursor-pointer`} src="/photos/Auth/Register/Checkbox.svg" alt="" onClick={() => setIsActive(!isActive)} />
                        <img className={`${isActive ? "block": "hidden"} w-5 cursor-pointer`} src="/photos/Auth/Register/CheckboxActive.svg" alt="" onClick={() => setIsActive(!isActive)} />
                        <p className="font-montserrat text-[10px] font-normal text-[#1B3C4D] uppercase">
                            Я принимаю условия и политику <br/>
                            конфиденциальности
                        </p>
                    </div>
                    <button
                        type="submit"
                        className="w-full bg-[#1B3C4D] py-5 rounded-2xl disabled:opacity-50"
                        disabled={isSubmitting || !isActive}
                    >
                        <p className="uppercase font-unbounded font-light text-white">зарегистрироваться</p>
                    </button>
                    <div className="text-center uppercase font-montserrat text-[#8296A6] text-[12px]">уже есть аккаунт? <span className="cursor-pointer text-black" onClick={() => {nav("/login")}}>Войти</span> </div>
                    <div className="w-full flex justify-center">
                        <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt=""/>
                    </div>
                </div>
            </div>
        </form>
    );
};

export default Register;