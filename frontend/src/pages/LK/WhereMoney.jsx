import React from 'react';
import { useNavigate } from "react-router-dom";
import api from '../../utils/api';
import { useAuth } from '../../contexts/AuthContext';

const WhereMoney = () => {
    const [step, setStep] = React.useState(0);
    const [isActive, setIsActive] = React.useState(false);
    const nav = useNavigate();
    const { isAuthenticated } = useAuth(); // Получаем статус авторизации
    const [isLoading, setIsLoading] = React.useState(true);
    const [paymentStatus, setPaymentStatus] = React.useState(null); // 'paid', 'unpaid', 'checking'

    // Проверяем авторизацию и статус платежа при монтировании
    React.useEffect(() => {
        const checkAuthAndPayment = async () => {
            setIsLoading(true);

            if (isAuthenticated) {
                try {
                    // Проверяем статус платежа
                    const paymentResponse = await api.get('/api/v1/payment/info');

                    if (paymentResponse.data.payment_status === 'paid') {
                        setPaymentStatus('paid');
                        nav("/LK"); // Если оплачено, редирект на /LK
                        return;
                    } else {
                        setPaymentStatus('unpaid');
                        setStep(1); // Если не оплачено, показываем шаг оплаты
                    }
                } catch (error) {
                    console.error('Ошибка проверки платежа:', error);
                    setPaymentStatus('unpaid');
                    setStep(1); // В случае ошибки показываем шаг оплаты
                }
            } else {
                setPaymentStatus('unpaid');
                setStep(0); // Показываем шаг входа/регистрации
            }

            setIsLoading(false);
        };

        checkAuthAndPayment();
    }, [isAuthenticated, nav]);

    const handleContinue = async () => {
        if (!isActive) return; // Если чекбокс не отмечен

        try {
            setIsLoading(true);
            // Получаем ссылку на оплату
            const paymentResponse = await api.get('/api/v1/payment/link');
            const paymentLink = paymentResponse.data.link;

            // Открываем платежную страницу в новом окне
            const paymentWindow = window.open(paymentLink, '_blank');

            // Проверяем статус платежа каждые 5 секунд
            const interval = setInterval(async () => {
                try {
                    const statusResponse = await api.get('/api/v1/payment/info');

                    if (statusResponse.data.payment_status === 'paid') {
                        clearInterval(interval);
                        nav("/LK"); // После успешной оплаты редирект на /LK
                    } else if (statusResponse.data.payment_status === 'failed') {
                        clearInterval(interval);
                        alert('Оплата не прошла. Пожалуйста, попробуйте снова.');
                    }
                } catch (error) {
                    console.error('Ошибка проверки статуса платежа:', error);
                }
            }, 5000);

            // Очищаем интервал при закрытии компонента
            return () => clearInterval(interval);
        } catch (error) {
            console.error('Ошибка при получении ссылки на оплату:', error);
            alert('Не удалось получить ссылку на оплату. Пожалуйста, попробуйте позже.');
        } finally {
            setIsLoading(false);
        }
    };

    // Если проверка еще не завершена, показываем загрузку
    if (isLoading) {
        return (
            <div className="w-full h-screen flex items-center justify-center bg-[#C2CED8]">
                <div className="text-center">
                    <p className="text-[#1B3C4D] font-montserrat">Проверка статуса...</p>
                    {/* Можно добавить спиннер загрузки */}
                </div>
            </div>
        );
    }

    return (
        <div className="w-full h-screen relative">
            <img
                src="/photos/LK/WomanLK.png"
                alt=""
                className="absolute top-0 left-0 w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-white opacity-70" />

            {step === 0 && (
                <div className="absolute inset-0 flex items-center justify-center">
                    <div className="flex flex-col items-center justify-end lg:gap-6 gap-3 text-[#1B3C4D] lg:h-[75%] h-[60%] max-w-md px-6 w-full">
                        <button
                            className="w-full bg-[#1B3C4D] py-5 rounded-2xl"
                            onClick={() => nav("/login")}
                        >
                            <p className="uppercase font-unbounded font-light text-[14px] text-white">
                                Войти
                            </p>
                        </button>
                        <button
                            className="w-full py-5 rounded-2xl border border-[#1B3C4D]"
                            onClick={() => nav("/register")}
                        >
                            <p className="uppercase font-unbounded font-light text-[14px] text-[#1B3C4D]">
                                Зарегистрироваться
                            </p>
                        </button>
                        <div className="w-full hidden lg:flex justify-center mt-7">
                            <img
                                src="/photos/Auth/Register/cross-svgrepo-com.svg"
                                className="w-8 cursor-pointer"
                                alt=""
                                onClick={() => nav("/")}
                            />
                        </div>
                    </div>
                </div>
            )}

            {step === 1 && (
                <div className="absolute inset-0 flex items-center justify-center">
                    <div className="flex flex-col items-center justify-between lg:gap-6 gap-3 text-[#1B3C4D] lg:h-[75%] h-[60%] max-w-md px-6 w-full">
                        <p className="text-[25px] font-unbounded lg:font-medium font-thin lg:text-left text-center uppercase w-full">
                            оплатите доступ <br /> к сервису
                        </p>

                        <p className="text-[15px] font-montserrat lg:font-medium lg:block hidden font-normal uppercase lg:text-left text-center w-full">
                            наш AI проанализирует черты лица <br />
                            и определит типаж
                        </p>

                        <p className="text-[12px] font-montserrat lg:font-medium lg:hidden font-normal uppercase lg:text-left text-center w-full">
                            наш <span className="font-medium">AI</span> проанализирует черты лица <br />
                            и определит типаж
                        </p>

                        <div className="border-x border-[#1B3C4D] lg:block hidden rounded-2xl p-3 text-center w-full">
                            <p className="uppercase text-[15px] text-[#1B3C4D]">
                                В подарок ты получишь мини-гайд <br />
                                о своем типаже
                            </p>
                        </div>

                        <div className="border-x border-[#1B3C4D] lg:hidden rounded-2xl p-3 text-center w-full">
                            <p className="uppercase font-normal text-[12px] text-[#1B3C4D]">
                                <span className="font-medium">В подарок </span> ты получишь мини-гайд <br />
                                о своем типаже
                            </p>
                        </div>

                        <p className="text-[#1B3C4D] font-medium text-[30px] font-unbounded">
                            3990 ₽
                        </p>
                        <div className="flex items-start gap-3 w-full">
                            <img
                                className={`w-5 cursor-pointer ${isActive ? "hidden" : "block"}`}
                                src="/photos/Auth/Register/Checkbox.svg"
                                alt=""
                                onClick={() => setIsActive(!isActive)}
                            />
                            <img
                                className={`w-5 cursor-pointer ${isActive ? "block" : "hidden"}`}
                                src="/photos/Auth/Register/CheckboxActive.svg"
                                alt=""
                                onClick={() => setIsActive(!isActive)}
                            />
                            <p className="font-montserrat text-[10px] font-normal text-[#1B3C4D] uppercase leading-tight">
                                Я согласен с условиями <br className="lg:block hidden"/>
                                лицензионного <br className="lg:hidden"/> соглашения
                            </p>
                        </div>
                        <button
                            className="w-full bg-[#1B3C4D] py-5 rounded-2xl disabled:opacity-50"
                            disabled={!isActive || isLoading}
                            onClick={handleContinue}
                        >
                            <p className="uppercase font-unbounded font-light text-[14px] text-white">
                                {isLoading ? 'Обработка...' : 'продолжить'}
                            </p>
                        </button>
                        <div className="w-full hidden lg:flex justify-center mt-7">
                            <img
                                src="/photos/Auth/Register/cross-svgrepo-com.svg"
                                className="w-8 cursor-pointer"
                                alt=""
                                onClick={() => nav("/")}
                            />
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default WhereMoney;