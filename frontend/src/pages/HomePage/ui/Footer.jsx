import React from 'react';
import { useNavigate } from "react-router-dom";
import { MAIN } from "../../../app/routes/constans.js";

const Footer = () => {
    const nav = useNavigate();
    const [copied, setCopied] = React.useState(false);

    return (
        <div className="relative w-full h-auto z-30 text-[#1B3C4D]">
            <div className="absolute top-0 left-0 w-full h-full bg-white" />
            <div className="w-full lg:px-60 px-5 lg:py-20 pt-20 pb-5 flex lg:flex-row lg:justify-between flex-col gap-5 relative">
                <div className="flex flex-col lg:justify-between gap-5 lg:min-h-[200px]">
                    <div className="flex flex-col lg:gap-10 gap-5 lg:items-start items-center">
                        <img
                            src="/photos/main/MNEIDET_BLUE.svg"
                            alt=""
                            className="w-[150px] cursor-pointer"
                            onClick={() => nav(MAIN)}
                        />
                        <p
                            onClick={() => {
                                navigator.clipboard.writeText("support@mne-idet.ru");
                                setCopied(true);
                                setTimeout(() => setCopied(false), 2000);
                            }}
                            className="lg:font-montserrat font-unbounded lg:uppercase lg:text-[20px] lg:font-light font-semibold lg:text-left text-center w-full lg:my-0 my-3 cursor-pointer transition-colors duration-200"
                        >
                            {copied ? "Почта скопирована" : "support@mne-idet.ru"}
                        </p>
                    </div>
                    <p className="font-montserrat uppercase text-[12px] font-light lg:block hidden">
                        ИП Трофимова Мария Андреевна<br />ИНН 230115188508<br />ОГРНИП 319237500065543
                    </p>
                </div>
                <div className="flex flex-col lg:justify-between gap-5 lg:min-h-[250px]">
                    <div className="flex flex-col gap-2">
                        <a className="font-montserrat text-[16px] font-light cursor-pointer lg:text-left text-center" href="#why-main">Преимущества</a>
                        <a className="font-montserrat text-[16px] font-light cursor-pointer lg:text-left text-center" href="#about">О сервисе</a>
                        <a className="font-montserrat text-[16px] font-light cursor-pointer lg:text-left text-center" href="#questions">Ответы на вопросы</a>
                        <a className="font-montserrat text-[16px] font-light cursor-pointer lg:text-left text-center" href="#examples">Результаты</a>
                    </div>
                    <div className="flex flex-row items-center lg:justify-end justify-center gap-5 lg:my-0 my-5">
                        <a href="https://t.me/mne_idet" target="_blank" rel="noopener noreferrer">
                            <img src="/photos/main/TG.svg" alt="Telegram" />
                        </a>
                        <a href="https://www.youtube.com/@mneidet" target="_blank" rel="noopener noreferrer">
                            <img src="/photos/main/YT.svg" alt="YouTube" />
                        </a>
                    </div>
                </div>
            </div>

            <div className="w-full lg:flex hidden justify-center items-center">
                <div className="w-[90%] border-b border-black relative" />
            </div>

            <div className="w-full lg:px-60 px-5 lg:pt-10 pb-20 flex lg:flex-row flex-col items-center justify-start lg:gap-16 gap-0 relative">
                <a
                    className="font-montserrat text-[14px] font-light underline cursor-pointer"
                    href="https://mneidet.com/privacy/"
                    target="_blank"
                    rel="noopener noreferrer"
                >
                    Условия использования
                </a>
                <a
                    className="font-montserrat text-[14px] font-light underline cursor-pointer"
                    href="https://mneidet.com/privacy/"
                    target="_blank"
                    rel="noopener noreferrer"
                >
                    Политика конфиденциальности
                </a>
                <p className="font-montserrat uppercase text-[12px] pt-3 text-center text-black font-light lg:hidden block lg:mt-0 mt-5">
                    ИП Трофимова Мария Андреевна<br />ИНН 230115188508<br />ОГРНИП 319237500065543
                </p>
            </div>
        </div>
    );
};

export default Footer;