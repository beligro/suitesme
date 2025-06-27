import React from 'react';
import { useNavigate } from "react-router-dom";

const WhereMoney = () => {
    const [step, setStep] = React.useState(0);
    const [isActive, setIsActive] = React.useState(false);
    const nav = useNavigate();
    const [isLoading, setIsLoading] = React.useState(true);


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