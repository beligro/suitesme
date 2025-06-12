import React from 'react';

const TopMain = () => {

    const [isBouncing, setIsBouncing] = React.useState(false);
    const [isOpen, setIsOpen] = React.useState(false);

    React.useEffect(() => {
        const interval = setInterval(() => {
            setIsBouncing(prev => !prev);
        }, 2000);

        return () => clearInterval(interval);
    }, []);

    return (
        <div className="w-full lg:h-auto h-[700px] relative bg-white">
            <img className="lg:w-full lg:h-auto h-[400px] object-cover z-0 top-0" src="/photos/main/main-top.webp" alt="" />
            <div className="relative lg:hidden h-[300px] bg-[rgba(130,148,155,0.7)] overflow-visible">
                <div className="absolute bottom-[-10px] left-0 w-full h-[200px] blur-[60px] bg-gradient-to-t from-white via-gray-100 to-[rgba(130,148,155,0.1)] z-0" />
            </div>
            <img className="h-full w-[50%]  z-10 absolute top-0 right-0 lg:block hidden" src="/photos/main/Rectangle.png" alt="" />
            <img className="h-full w-[30%]  z-10 absolute top-0 right-0 lg:block hidden" src="/photos/main/Rectangle.png" alt="" />
            <div className="backdrop-blur-xl z-30 w-full lg:h-[130px] h-[60px] absolute top-0 left-0 flex flex-row items-center justify-between lg:px-20 px-5">
                <img src="/photos/main/Profile.svg" className="h-[20px] lg:hidden block cursor-pointer" alt="" />
                <img className="w-[110px]" src="/photos/main/MNEIDET.svg" alt="" />
                <img src="/photos/main/Burger.svg" className="h-[20px] lg:hidden block cursor-pointer" alt="" onClick={() => setIsOpen(!isOpen)}/>
                <div className="lg:flex flex-row xl:gap-[35px] gap-[20px] items-center justify-end hidden">
                    <a className="font-montserrat font-medium text-[16px] text-white whitespace-nowrap cursor-pointer" href='#why-main'>Преимущества</a>
                    <a className="font-montserrat font-medium text-[16px] text-white whitespace-nowrap cursor-pointer" href='#about'>О сервисе</a>
                    <a className="font-montserrat font-medium text-[16px] text-white whitespace-nowrap cursor-pointer" href='#questions'>Ответы на вопросы</a>
                    <a className="font-montserrat font-medium text-[16px] text-white whitespace-nowrap cursor-pointer" href='#examples'>Примеры результатов</a>
                    <a className="px-3 py-2 rounded-full !border text-[16px] !border-white font-light uppercase text-white font-unbounded cursor-pointer">войти</a>
                </div>
            </div>
            <div className="absolute z-10 lg:top-36 top-[300px] lg:left-[20%] lg:w-[250px] w-full lg:text-left text-center lg:p-0 p-16">
                <p className="lg:font-normal font-light font-unbounded xl:text-[40px] lg:text-[30px] text-[23px] uppercase text-white">
                    Узнай, что тебе&nbsp;действи&shy;тельно идёт
                </p>
                <p className="font-normal mt-5 text-[12px] lg:w-[217px] text-center uppercase text-white lg:border-x lg:border-white lg:px-3 lg:py-2 lg:rounded-2xl">
                    Наш искусственный интеллект анализирует черты лица и определяет типаж по системе
                    <span className="block font-semibold">MNE IDET</span>
                </p>
                <div className="lg:hidden mx-auto mt-10 top-[85%] w-[240px] h-[50px] flex items-center justify-center rounded-full bg-[#23274B] text-white uppercase text-[14px] font-light cursor-pointer hover:shadow-xl transition duration-200">
                    Узнай свой типаж
                </div>
            </div>
            <div className="absolute left-1/2 transform -translate-x-1/2 top-[85%] w-[240px] h-[50px] lg:flex hidden items-center justify-center rounded-full bg-[#23274B] text-white uppercase text-[14px] font-light cursor-pointer hover:shadow-xl transition duration-200">
                Узнай свой типаж
            </div>
            <img style={{ transitionDuration: '2000ms' }} className={`absolute w-auto z-20 transform ease-in-out lg:left-0 md:-left-[20%] -left-[50%] ${isBouncing ? "top-[10%]" : "top-[5%]" }`} src="/photos/main/Soplya.png" alt=""/>
            <img style={{ transitionDuration: '2000ms' }} className={`absolute z-20 lg:right-0 md:-right-[20%] -right-[50%] transform ease-in-out ${isBouncing ? "top-[0%]" : "-top-[5%]" }`} src="/photos/main/Soplya3.png" alt=""/>
            <div className={`${isOpen ? "flex" : "hidden"} w-full z-50 absolute top-0 left-0 flex-col bg-[rgb(130,148,155)] h-full`}>
                <div className="w-full flex mt-5">
                    <img src="/photos/main/MNEIDET.svg" alt="" className="mx-auto h-[20px]"/>
                    <img src="/photos/main/cross-svgrepo-com.svg" alt="" className="absolute right-5 top-3 w-[36px] cursor-pointer" onClick={() => setIsOpen(!isOpen)}/>
                </div>
                <div className="w-full flex flex-col items-center justify-center">
                    <div className="flex flex-col gap-5 sm:mt-[7%] mt-[20%]">
                        <a className="font-montserrat font-medium text-[16px] text-white whitespace-nowrap cursor-pointer" href='#why-main'>Преимущества</a>
                        <a className="font-montserrat font-medium text-[16px] text-white whitespace-nowrap cursor-pointer" href='#about'>О сервисе</a>
                        <a className="font-montserrat font-medium text-[16px] text-white whitespace-nowrap cursor-pointer"  href='#questions'>Ответы на вопросы</a>
                        <a className="font-montserrat font-medium text-[16px] text-white whitespace-nowrap cursor-pointer" href='#examples' >Результаты</a>
                    </div>
                    <div className="flex w-full flex-col gap-3 items-center justify-center sm:mt-[7%] mt-[20%]">
                        <div className="w-16 h-16 border rounded-full border-white flex items-center justify-center">
                            <img src="/photos/main/Profile.svg" className="w-8 cursor-pointer" alt=""/>
                        </div>
                        <p className="text-center font-montserrat font-light text-[20px] text-white cursor-pointer">Войти</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default TopMain;