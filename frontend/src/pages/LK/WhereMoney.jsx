import React, {useEffect, useState} from 'react';
import {useLocation, useNavigate} from "react-router-dom";
import {$authHost} from "../../app/indexAPI.js";
import {LK} from "../../app/routes/constans.js";
import { getPublicSettings } from "../../app/settingsAPI.js";

const WhereMoney = () => {
    const [step, setStep] = useState(0);
    const [isActive, setIsActive] = useState(false);
    const nav = useNavigate();
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(false);
    const [isReady, setIsReady] = useState(false);
    const [price, setPrice] = useState("5990");
    const [euroPrice, setEuroPrice] = useState("");
    const [loadingProvider, setLoadingProvider] = useState(null);
    const location = useLocation();
    const queryParams = new URLSearchParams(location.search);
    const status = queryParams.get("status");

    //-----------API

    const getInfo = async () => {
        try {
            const response = await $authHost.get("style/info");
            return { status: response.status, data: response.data };
        } catch (error) {
            if (error.response) {
                return { status: error.response.status };
            } else {
                console.log("Unexpected error:", error);
                return { status: 500 };
            }
        }
    };

    const getLink = async (provider) => {
        try {
            const params = provider === "stripe" ? { params: { provider: "stripe" } } : {};
            const response = await $authHost.get("payment/link", params);
            return response.data;
        } catch (error) {
            console.log(error);
            return { status: ":(" };
        }
    }

    const payNotify = async () => {
        try {
            const {data} = await $authHost.post("payment/notify");
            return data;
        } catch (error) {
            console.log(error);
        }
    }

    const payInfo = async () => {
        try {
            const response = await $authHost.get("payment/info");
            return { status: response.status, data: response.data };
        } catch (error) {
            if (error.response) {
                return { status: error.response.status };
            } else {
                console.log("Unexpected error:", error);
                return { status: 500 };
            }
        }
    };

    //-------------

    const getPaymentStatus = async () => {
        setIsLoading(true);
        const response = await getInfo();

        if (response.status === 403) {
            setStep(1);
        } else if (response.status === 404 || response.status === 200) {
            nav(LK , { replace: true });
        } else {
            setStep(0);
        }
        setIsReady(true);

        setIsLoading(false);
    };

    const getPayment = async (provider) => {
        const key = provider === "stripe" ? "stripe" : "prodamus";
        setLoadingProvider(key);
        const response = await getLink(provider);
        if (response && response.link) {
            window.location.href = response.link;
        } else {
            setError(true);
            setLoadingProvider(null);
        }
    };

    const paymentCheck = async () => {
        if (status !== "ok") {
            setIsLoading(false);
            setError(true);
            setStep(1);
            return;
        }

        setIsLoading(true);
        setIsReady(true);

        try {
            const response = await payNotify();

            if (!response || (response.status !== 200 && response.status !== 204)) {
                console.warn("payNotify вернул неожиданный статус:", response?.status);
            }
        } catch (error) {
            console.warn("payNotify упал, продолжаем polling:", error?.response?.status || error);
        }

        const maxAttempts = 60;
        let attempts = 0;

        const poll = async () => {
            try {
                const info = await payInfo();

                setIsLoading(true);

                if (info.status === 200 && info.data.payment_status	=== "paid") {
                    nav(LK);
                    return;
                }

                if (info.status === 200 && info.data.payment_status	=== "failed") {
                    setIsLoading(false);
                    setStep(1);
                    setError(true);
                    return;
                }

                if (++attempts >= maxAttempts) {
                    setError(true);
                    setIsLoading(false);
                    return;
                }

                setTimeout(poll, 2000);
            } catch (error) {
                console.error("Polling error:", error);
                if (++attempts >= maxAttempts) {
                    setError(true);
                    setIsLoading(false);
                } else {
                    setTimeout(poll, 2000);
                }
            }
        };

        poll();
    };

    useEffect(() => {
        if (status === "ok") {
            paymentCheck();
        } else if (status === "fail") {
            setError(true);
            getPaymentStatus();
        } else {
            getPaymentStatus();
        }
    }, []);

    useEffect(() => {
        const fetchSettings = async () => {
            const settings = await getPublicSettings();
            if (settings.price) setPrice(settings.price);
            if (settings.euro_price) setEuroPrice(settings.euro_price);
        };
        fetchSettings();
    }, []);

    if (!isReady) return null;

    return (
        <div className="w-full h-screen relative">
            <img
                src="/photos/LK/WomanLK.png"
                alt=""
                className="absolute top-0 left-0 w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-white opacity-70" />

            {isLoading && (
                <div className="absolute w-full top-[30%] flex flex-col gap-5 items-center justify-center">
                    <img src="/photos/LK/Krutilcka.svg" alt="" className="w-48"/>
                    <p className="text-center text-[#1B3C4D] font-light font-montserrat text-[14px] uppercase">еще пару мгновений,<br />
                        проверяем оплату...</p>
                </div>
            )}

            {step === 0 && !isLoading && (
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
                        <div className="w-full flex justify-center mt-7">
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

            {step === 1 && !isLoading && (
                <div className="absolute inset-0 flex items-center justify-center">
                    <div className="flex flex-col items-center justify-between lg:gap-6 gap-3 text-[#1B3C4D] lg:h-[75%] h-[60%] max-w-md px-6 w-full relative">
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
                            {price} ₽
                        </p>
                        {euroPrice && (
                            <p className="text-[#1B3C4D] font-medium text-[30px] font-unbounded -mt-2">
                                ({euroPrice} €)
                            </p>
                        )}
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
                                Нажимая кнопку «ОПЛАТИТЬ», я даю{' '}
                                <a
                                    href="https://disk.yandex.ru/i/sm5-QrrMwvgcCg"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="underline cursor-pointer"
                                >
                                    Согласие на обработку персональных данных
                                </a>
                                {' '}и принимаю{' '}
                                <a
                                    href="https://disk.yandex.ru/i/i5Z9cm8HvkNHYA"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="underline cursor-pointer"
                                >
                                    Политику конфиденциальности
                                </a>
                            </p>
                        </div>
                        <div className="w-full relative flex flex-col gap-3">
                            <button
                                className="w-full bg-[#1B3C4D] py-5 rounded-2xl disabled:opacity-50 relative overflow-hidden"
                                disabled={!isActive || loadingProvider !== null}
                                onClick={() => getPayment()}
                            >
                                {loadingProvider === "prodamus" && (
                                    <div className="absolute inset-0 z-0 bg-gradient-to-r from-transparent via-white/30 to-transparent animate-button-shimmer" />
                                )}
                                <p className="uppercase font-unbounded font-light text-[14px] text-white relative z-10">
                                    Оплатить российской картой
                                </p>
                            </button>
                            {euroPrice && (
                                <button
                                    className="w-full py-5 rounded-2xl border border-[#1B3C4D] disabled:opacity-50 relative overflow-hidden"
                                    disabled={!isActive || loadingProvider !== null}
                                    onClick={() => getPayment("stripe")}
                                >
                                    {loadingProvider === "stripe" && (
                                        <div className="absolute inset-0 z-0 bg-gradient-to-r from-transparent via-[#1B3C4D]/20 to-transparent animate-button-shimmer" />
                                    )}
                                    <p className="uppercase font-unbounded font-light text-[14px] text-[#1B3C4D] relative z-10">
                                        Оплатить иностранной картой
                                    </p>
                                </button>
                            )}
                            {error && (
                                <p className="text-center w-full text-red-500 uppercase text-[14px] font-medium">ошибка оплаты</p>
                            )}
                        </div>
                        <div className="text-center"></div>
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