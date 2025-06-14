import React, {useEffect, useRef, useState} from 'react';
import {useNavigate} from "react-router-dom";
import {publicApi} from "../../../utils/api.js";
import useForm from "../../../hooks/useForm.js";

const ForgotPassword = () => {

    const [step, setStep] = useState(0);
    const [code, setCode] = useState(['', '', '', '']);
    const inputRefs = useRef([]);
    const nav = useNavigate()


    const handleCodeChange = (value, index) => {
        if (!/^\d?$/.test(value)) return;

        const newCode = [...code];
        newCode[index] = value;
        setCode(newCode);

        if (value && index < code.length - 1) {
            inputRefs.current[index + 1]?.focus();
        }
    };

    const handleKeyDown = (e, index) => {
        if (e.key === 'Backspace' && !code[index] && index > 0) {
            inputRefs.current[index - 1]?.focus();
        }
    };

    const [time, setTime] = useState(40);
    const [intervalId, setIntervalId] = useState(null);

    useEffect(() => {
        startTimer();
        return () => clearInterval(intervalId);
    }, []);

    const startTimer = () => {
        const id = setInterval(() => {
            setTime(prev => {
                if (prev <= 1) {
                    clearInterval(id);
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);
        setIntervalId(id);
    };

    const handleResend = () => {
        setTime(30);
        startTimer();
    };



    const onSubmit = async (formValues) => {
        setStep(1);
        await handleForgotPasswordSubmit(formValues);
    };

    const validationRules = {
        email: [
            { type: 'required', message: 'Email обязателен' },
            { type: 'email', message: 'Некорректный формат email' }
        ]
    };

    // Обработчик отправки формы
    const handleForgotPasswordSubmit = async (values) => {
        try {
            await publicApi.post('/api/v1/auth/forgot_password', { email: values.email });
            return true;
        } catch (error) {
            console.error('Ошибка при отправке письма для восстановления пароля:', error);
            throw new Error('Не удалось отправить письмо. Пожалуйста, проверьте email и попробуйте снова.');
        }
    };

    // Инициализируем хук формы
    const {
        values,
        errors,
        handleChange,
    } = useForm(
        { email: '' },
        validationRules,
        handleForgotPasswordSubmit
    );

    const passwordValidationRules = {
        password: [
            { type: 'required', message: 'Пароль обязателен' },
            { type: 'minLength', value: 6, message: 'Пароль должен содержать минимум 6 символов' }
        ],
        password_confirm: [
            { type: 'required', message: 'Подтверждение пароля обязательно' },
            { type: 'match', field: 'password', message: 'Пароли не совпадают' }
        ]
    };

    const handlePasswordResetSubmit = async (values) => {
        const resetToken = code.join('');
        if (resetToken.length < 4) {
            throw new Error('Неверный код подтверждения');
        }

        try {
            await publicApi.post('/api/v1/auth/password/reset', {
                reset_token: resetToken,
                password: values.password,
                password_confirm: values.password_confirm,
            });
            setStep(3); // успех
            return true;
        } catch (error) {
            console.error('Ошибка при сбросе пароля:', error);
            throw new Error(error.response?.data?.message || 'Ошибка при сбросе пароля. Попробуйте снова.');
        }
    };

    const {
        values: passwordValues,
        errors: passwordErrors,
        handleChange: handlePasswordChange,
        handleSubmit: handlePasswordSubmit,
        isSubmitting: isPasswordSubmitting
    } = useForm(
        { password: '', password_confirm: '' },
        passwordValidationRules,
        handlePasswordResetSubmit
    );

    return (
        <div>
            {step === 0 && (
                <div className="w-full min-h-screen flex justify-center items-center">
                    <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                        <div className="w-full h-full flex flex-col justify-between gap-10">
                            <div className="w-full flex flex-col gap-10 relative">
                                <div className="md:hidden flex flex-row items-center justify-between w-full">
                                    <img src="/photos/Auth/Back.svg" alt="" className="cursor-pointer w-10" onClick={() => {nav(-1)}}/>
                                    <img src="/photos/Auth/Star.svg" alt="" className="w-10" />
                                </div>

                                <img className="md:block hidden absolute -left-20 cursor-pointer" src="/photos/Auth/Back.svg" alt="" onClick={() => {nav(-1)}}/>

                                <p className="font-unbounded text-left md:uppercase font-medium text-[20px]">забыли пароль?</p>
                                <p className="uppercase text-[10px] font-medium font-montserrat w-full text-[#607E96]">не волнуйтесь! такое случается. Пожалуйста, введите адрес электронной почты , связанный с вашей учетной записью.</p>
                                <div className="w-full flex flex-col gap-2">
                                    <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">email</p>
                                    <input
                                        name="email"
                                        value={values.email}
                                        onChange={handleChange}
                                        className="border-b px-3 py-2 rounded-2xl"
                                    />
                                    {errors.email && (
                                        <p className="text-red-500 text-xs">{errors.email}</p>
                                    )}
                                </div>
                            </div>
                            <div className="w-full flex flex-col gap-10">
                                <button
                                    className="w-full bg-[#1B3C4D] py-5 rounded-2xl"
                                    onClick={() => {onSubmit()}}
                                >
                                    <p className="uppercase font-unbounded font-light text-white">отправить</p>
                                </button>
                                <div className="w-full flex justify-center">
                                    <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt=""/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
            {step === 1 && (
                <div className="w-full min-h-screen flex justify-center items-center">
                    <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                        <div className="w-full h-full flex flex-col justify-between gap-10">
                            <div className="w-full flex flex-col gap-10 relative">
                                <div className="md:hidden flex flex-row items-center justify-between w-full">
                                    <img src="/photos/Auth/Back.svg" alt="" className="cursor-pointer w-10" onClick={() => {nav(-1)}}/>
                                    <img src="/photos/Auth/Star.svg" alt="" className="w-10" />
                                </div>

                                <img className="md:block hidden absolute -left-20 cursor-pointer" src="/photos/Auth/Back.svg" alt="" onClick={() => {nav(-1)}}/>

                                <p className="font-unbounded text-left md:uppercase font-medium text-[20px]">пожалуйста, проверьте свою электронную почту</p>
                                <p className="uppercase text-[10px] font-medium font-montserrat w-full text-[#607E96]">мы отправили код по адресу {values.email}</p>

                                <div className="w-full flex justify-between gap-4">
                                    {code.map((digit, index) => (
                                        <input
                                            key={index}
                                            ref={(el) => (inputRefs.current[index] = el)}
                                            type="text"
                                            inputMode="numeric"
                                            maxLength={1}
                                            value={digit}
                                            onChange={(e) => handleCodeChange(e.target.value, index)}
                                            onKeyDown={(e) => handleKeyDown(e, index)}
                                            className="w-full aspect-square text-center text-2xl font-bold rounded-2xl border border-gray-300 focus:border-black outline-none transition-all"
                                        />
                                    ))}
                                </div>
                            </div>

                            <div className="w-full flex flex-col gap-10">

                                <p
                                    className={`text-center mb-5 font-montserrat ${time === 0 ? 'cursor-pointer text-blue-500' : 'text-gray-400 cursor-not-allowed'}`}
                                    onClick={time === 0 ? handleResend : undefined}
                                >
                                    {time === 0 ? "отправить код повторно" : time > 9 ? `отправить код повторно через 00:${time}` : `отправить код повторно через 00:0${time}`}
                                </p>

                                <button
                                    className="w-full bg-[#1B3C4D] py-5 rounded-2xl"
                                    onClick={() => {setStep(2)}}
                                >
                                    <p className="uppercase font-unbounded font-light text-white">отправить</p>
                                </button>
                                <div className="w-full flex justify-center">
                                    <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt=""/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
            {step === 2 && (
                <div className="w-full min-h-screen flex justify-center items-center">
                    <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                        <div className="w-full h-full flex flex-col justify-between gap-10">
                            <div className="w-full flex flex-col gap-10 relative">
                                <div className="md:hidden flex flex-row items-center justify-between w-full">
                                    <img src="/photos/Auth/Back.svg" alt="" className="cursor-pointer w-10" onClick={() => {nav(-1)}}/>
                                    <img src="/photos/Auth/Star.svg" alt="" className="w-10" />
                                </div>

                                <img className="md:block hidden absolute -left-20 cursor-pointer" src="/photos/Auth/Back.svg" alt="" onClick={() => {nav(-1)}}/>

                                <p className="font-unbounded text-left md:uppercase font-medium text-[20px]">введите новый пароль</p>
                                <p className="uppercase text-[10px] font-medium font-montserrat w-full text-[#607E96]">пожалуйста, придумайте сложный пароль</p>
                                <div className="w-full flex flex-col gap-2">
                                    <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">пароль</p>
                                    <input
                                        name="password"
                                        type="password"
                                        value={passwordValues.password}
                                        onChange={handlePasswordChange}
                                        className="border-b px-3 py-2 rounded-2xl"
                                    />
                                    {passwordErrors.password && <p className="text-red-500 text-xs">{passwordErrors.password}</p>}
                                </div>
                                <div className="w-full flex flex-col gap-2">
                                    <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">подтвердить пароль</p>
                                    <input
                                        name="password_confirm"
                                        type="password"
                                        value={passwordValues.password_confirm}
                                        onChange={handlePasswordChange}
                                        className="border-b px-3 py-2 rounded-2xl"
                                    />
                                    {passwordErrors.password_confirm && <p className="text-red-500 text-xs">{passwordErrors.password_confirm}</p>}
                                </div>
                            </div>
                            <div className="w-full flex flex-col gap-10">
                                <button
                                    className="w-full bg-[#1B3C4D] py-5 rounded-2xl"
                                    onClick={handlePasswordSubmit}
                                    disabled={isPasswordSubmitting}
                                >
                                    <p className="uppercase font-unbounded font-light text-white">отправить</p>
                                </button>
                                <div className="w-full flex justify-center">
                                    <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt=""/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
            {step === 3 && (
                <div className="w-full min-h-screen flex justify-center items-center">
                    <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                        <div className="w-full h-full flex flex-col justify-between gap-10">
                            <div className="w-full flex flex-col gap-5 justify-center items-center mt-14">
                                <img src="/photos/Auth/Star.svg" alt="" className="w-10 mb-5"/>
                                <p className="uppercase font-medium font-unbounded text-[#1B3C4D]">пароль изменен</p>
                                <p className="text-[#607E96] text-[10px] uppercase">ваш пароль был успешно изменен</p>
                            </div>
                            <div className="w-full flex flex-col gap-10">
                                <button className="w-full bg-[#1B3C4D] py-5 rounded-2xl" onClick={() => {nav("/")}}>
                                    <p className="uppercase font-unbounded font-light text-white">Вернуться ко входу</p>
                                </button>
                                <div className="w-full flex justify-center">
                                    <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt=""/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ForgotPassword;