import {useEffect, useState} from "react";
import { useNavigate } from "react-router-dom";
import {$host} from "../../../app/indexAPI.js";
import {LK} from "../../../app/routes/constans.js";
import { login } from "../../../features/Auth/model/slice.js";
import {useDispatch, useSelector} from "react-redux";
import {selectIsAuthenticated} from "../../../features/Auth/model/selector.js";

const Login = () => {
    const isAuth = useSelector(selectIsAuthenticated);
    const [showPassword, setShowPassword] = useState(false);
    const [values, setValues] = useState({ email: '', password: '' });
    const [errors, setErrors] = useState({});
    const [isSubmitting, setIsSubmitting] = useState(false);
    const dispatch = useDispatch();
    const [isModalErrorOpen, setIsModalErrorOpen] = useState(false);

    const nav = useNavigate();

    const handleChange = (e) => {
        const { name, value } = e.target;
        setValues((prev) => ({ ...prev, [name]: value }));
    };

    const validate = () => {
        const newErrors = {};

        if (!values.email) {
            newErrors.email = 'Email обязателен';
        } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(values.email)) {
            newErrors.email = 'Некорректный формат email';
        }

        if (!values.password) {
            newErrors.password = 'Пароль обязателен';
        }

        return newErrors;
    };

    const fetchLogin = async ({ email, password }) => {
        try {
            const response = await $host.post(`/auth/login`, { email, password });
            return response.data;
        } catch (error) {
            console.error(error);
            throw error;
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        const validationErrors = validate();
        setErrors(validationErrors);

        if (Object.keys(validationErrors).length > 0) return;

        setIsSubmitting(true);

        try {
            const data = await fetchLogin(values);

            dispatch(login(data));

            nav(LK);
        } catch (error) {
            console.error("Ошибка при входе:", error);
            setIsModalErrorOpen(true);
        } finally {
            setIsSubmitting(false);
        }
    };

    useEffect(() => {
        setTimeout(() => setIsModalErrorOpen(false), 10000);
    }, [handleSubmit])


    useEffect(() => {
        if (isAuth) {
            nav(LK, { replace: true });
        }
    }, [isAuth]);

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
                        <div className="w-full flex flex-col gap-2 h-full justify-center ">
                            <div className="w-full flex flex-col gap-1 mt-20">
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
                        {isModalErrorOpen && (
                            <div className="w-full absolute lg:-bottom-20 -bottom-8">
                                <p className="text-red-500 font-montserrat uppercase text-center whitespace-nowrap sm:text-[16px] text-[12px]"> неправильный логин или пароль</p>
                            </div>
                        )}
                    </div>
                    <div className="w-full flex flex-col gap-10">
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className="w-full bg-[#1B3C4D] py-5 rounded-2xl disabled:opacity-50 mb-32"
                        >
                            <p className="uppercase font-unbounded font-light text-white">войти</p>
                        </button>
                        <div className="text-center uppercase font-montserrat text-[#8296A6] text-[12px]">ЕЩЕ НЕТ аккаунтА? <span className="cursor-pointer text-black" onClick={() => {nav("/register")}}> ЗАРЕГИСТРИРОВАТЬСЯ</span> </div>
                        <div className="w-full hidden justify-center sm:flex">
                            <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt="" onClick={() => {nav("/")}} />
                        </div>
                    </div>
                </div>
            </div>
        </form>
    );
};

export default Login;