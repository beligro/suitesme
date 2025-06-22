import React from 'react';
import {useNavigate} from "react-router-dom";

const TopMain = () => {

    const [isBouncing, setIsBouncing] = React.useState(false);
    const [isOpen, setIsOpen] = React.useState(false);
    const nav = useNavigate();

    React.useEffect(() => {
        const interval = setInterval(() => {
            setIsBouncing(prev => !prev);
        }, 2000);

        return () => clearInterval(interval);
    }, []);

    React.useEffect(() => {
        if (isOpen) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = 'auto';
        }

        return () => {
            document.body.style.overflow = 'auto';
        };
    }, [isOpen]);

    return (
        <div className="w-full lg:h-auto min-h-screen relative bg-white">
            <img className="lg:w-full h-screen object-cover lg:ml-[10%] z-0 top-0 lg:block hidden" src="/photos/main/main-top.webp" alt="" />
            <img className="w-full h-[500px] object-cover z-0 top-0 lg:hidden" src="/photos/main/top-main2.png" alt="" />


            <img
                className="absolute top-[400px] w-full md:h-[460px] sm:h-[380px] h-[300px] lg:hidden object-cover"
                src="/photos/main/TopBlur.svg"
                alt=""
            />
            <img
                className="lg:hidden absolute md:top-[750px] sm:top-[670px] top-[590px] w-full h-[120px] object-cover"
                src="/photos/main/BottomBlur.png"
                alt=""
            />

            <img className="h-full w-[30%]  z-10 absolute top-0 left-0 lg:block hidden" src="/photos/main/LeftBlur.png" alt="" />
            <img className="h-full w-[30%]  z-10 absolute top-0 right-0 lg:block hidden" src="/photos/main/Rectangle.png" alt="" />
            <div className="backdrop-blur-sm z-30 w-full lg:h-[130px] h-[60px] absolute top-0 left-0 flex flex-row items-center justify-between lg:px-20 px-5">
                <img src="/photos/main/Profile.svg" className="h-[20px] lg:hidden block cursor-pointer" alt="" />
                <img className="w-[110px]" src="/photos/main/MNEIDET.svg" alt="" />
                <img src="/photos/main/Burger.svg" className="h-[20px] lg:hidden block cursor-pointer" alt="" onClick={() => setIsOpen(!isOpen)}/>
                <div className="lg:flex flex-row xl:gap-[45px] gap-[25px] items-center justify-end hidden">
                    <a className="font-montserrat font-medium text-[12px] text-white whitespace-nowrap cursor-pointer" href='#why-main'>Преимущества</a>
                    <a className="font-montserrat font-medium text-[12px] text-white whitespace-nowrap cursor-pointer" href='#about'>О сервисе</a>
                    <a className="font-montserrat font-medium text-[12px] text-white whitespace-nowrap cursor-pointer" href='#questions'>Ответы на вопросы</a>
                    <a className="font-montserrat font-medium text-[12px] text-white whitespace-nowrap cursor-pointer" href='#examples'>Примеры результатов</a>
                    <a className="px-7 h-12 flex items-center justify-center rounded-full !border text-[11px] !border-white font-light uppercase text-white font-unbounded cursor-pointer" onClick={() => nav("/login")}>войти</a>
                </div>
            </div>
            <div className="absolute z-10 lg:top-36 top-[380px] lg:left-[20%] lg:w-[250px] w-full lg:text-left text-center lg:p-0 p-16">
                <p className="lg:font-extralight font-light font-unbounded xl:text-[50px] lg:text-[30px] text-[23px] uppercase text-white">
                    Узнай, что тебе&nbsp;действи&shy;тельно идёт
                </p>
                <p className="font-normal mt-5 text-[12px] lg:w-[230px] text-center uppercase text-white lg:border-x lg:border-white lg:px-3 lg:py-2 lg:rounded-2xl">
                    Наш искусственный интеллект анализирует черты лица и определяет типаж по системе
                    <span className="block font-semibold">MNE IDET</span>
                </p>
                <div className="lg:hidden mx-auto mt-24 md:mt-10 top-[85%] w-[240px] h-[50px] flex items-center justify-center rounded-full bg-[#1B3C4D] text-white uppercase text-[14px] font-light cursor-pointer hover:shadow-xl transition duration-200" onClick={() => nav("/LK")}>
                    Узнай свой типаж
                </div>
            </div>
            <div className="absolute left-1/2 transform -translate-x-1/2 top-[85%] w-[240px] h-[50px] lg:flex hidden items-center justify-center rounded-full bg-[#1B3C4D] text-white uppercase text-[12px] font-light cursor-pointer hover:shadow-xl transition duration-200 font-unbounded z-50"
                 onClick={() => nav("/LK")}
            >
                Узнай свой типаж
            </div>
            <img style={{ transitionDuration: '2000ms' }} className={`absolute h-[750px] w-auto z-20 transform ease-in-out lg:left-0 md:-left-[50%] -left-[40%] ${isBouncing ? "lg:top-[10%] -top-[20%]" : "lg:top-[5%] -top-[25%]" }`} src="/photos/main/Soplya.png" alt=""/>
            <img style={{ transitionDuration: '2000ms' }} className={`absolute h-[580px] z-20 lg:right-0 md:-right-[20%] -right-[50%] transform ease-in-out ${isBouncing ? "top-[0%]" : "-top-[5%]" }`} src="/photos/main/Soplya3.png" alt=""/>
            <div className={`${isOpen ? "flex" : "hidden"} w-full z-50 absolute top-0 left-0 flex-col bg-[rgb(130,148,155)] h-full`}>
                <div className="w-full flex mt-5">
                    <img src="/photos/main/MNEIDET.svg" alt="" className="mx-auto h-[20px]"/>
                    <img src="/photos/main/cross-svgrepo-com.svg" alt="" className="absolute right-5 top-3 w-[36px] cursor-pointer" onClick={() => setIsOpen(!isOpen)}/>
                </div>
                <div className="w-full flex flex-col items-center justify-center h-full gap-14">
                    <div className="flex flex-col gap-5 text-center">
                        <a className="font-montserrat font-normal text-[16px] text-white whitespace-nowrap cursor-pointer" href='#why-main'>Преимущества</a>
                        <a className="font-montserrat font-normal text-[16px] text-white whitespace-nowrap cursor-pointer" href='#about'>О сервисе</a>
                        <a className="font-montserrat font-normal text-[16px] text-white whitespace-nowrap cursor-pointer"  href='#questions'>Ответы на вопросы</a>
                        <a className="font-montserrat font-normal text-[16px] text-white whitespace-nowrap cursor-pointer" href='#examples'>Результаты</a>
                    </div>
                    <div className="flex w-full flex-col gap-3 items-center justify-center">
                        <div className="w-12 h-12 border rounded-full border-white flex items-center justify-center cursor-pointer" onClick={() => nav("/login")}>
                            <img src="/photos/main/Profile.svg" className="w-6" alt=""/>
                        </div>
                        <p className="text-center font-montserrat font-light text-[16px] text-white cursor-pointer" onClick={() => nav("/login")}>Войти</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default TopMain;