import React from 'react';
import {useNavigate} from "react-router-dom";

const WhereMoney = () => {


    const [step, setStep] = React.useState(0); //
    const [isActive, setIsActive] = React.useState(false);
    const nav = useNavigate()


    return (
        <div className={`w-full lg:h-auto h-screen relative`}>
            <img src="/photos/LK/WomanLK.png" alt="" className={` absolute top-0 left-0 w-full h-screen object-cover `} />
            <div className={`w-full h-screen absolute bg-[#ffffff] opacity-70 `} />

            {step === 0 && (
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md px-4 lg:h-[60%] h-[70%] flex flex-col gap-6 items-center justify-center text-[#1B3C4D] text-center">

                    <p className="text-[25px] font-unbounded font-medium uppercase leading-tight">
                        оплатите доступ <br /> к сервису
                    </p>

                    <p className="text-[15px] font-montserrat font-medium uppercase">
                        наш AI проанализирует черты лица <br />
                        и определит типаж
                    </p>

                    <div className="w-full border-x border-[#1B3C4D] rounded-md py-2">
                        <p className="uppercase text-[15px] font-montserrat">
                            В подарок ты получишь мини-гайд <br />
                            о своем типаже
                        </p>
                    </div>

                    <p className="text-[#1B3C4D] font-medium text-[30px] font-unbounded">3990 ₽</p>

                    <div className="flex flex-row items-start gap-3">
                        <img
                            className={`${isActive ? "hidden" : "block"} w-5 cursor-pointer`}
                            src="/photos/Auth/Register/Checkbox.svg"
                            alt=""
                            onClick={() => setIsActive(!isActive)}
                        />
                        <img
                            className={`${isActive ? "block" : "hidden"} w-5 cursor-pointer`}
                            src="/photos/Auth/Register/CheckboxActive.svg"
                            alt=""
                            onClick={() => setIsActive(!isActive)}
                        />
                        <p className="font-montserrat text-[10px] font-normal uppercase text-left">
                            Я согласен с условиями <br /> лицензионного соглашения
                        </p>
                    </div>

                    <button
                        className="w-full bg-[#1B3C4D] py-5 rounded-2xl disabled:opacity-50"
                    >
                        <p className="uppercase font-unbounded font-light text-[14px] text-white">продолжить</p>
                    </button>

                    <div className="hidden sm:flex justify-center w-full">
                        <img
                            src="/photos/Auth/Register/cross-svgrepo-com.svg"
                            className="w-8 cursor-pointer"
                            alt=""
                            onClick={() => { nav("/") }}
                        />
                    </div>
                </div>
            )}


        </div>
    );
};

export default WhereMoney;