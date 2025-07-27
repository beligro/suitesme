import React from 'react';
import SectionWrapper from "../../../hoc/SectionWrapper.jsx";
import {useNavigate} from "react-router-dom";

const CenterFirst = () => {

    const [isBouncing, setIsBouncing] = React.useState(false);
    const nav = useNavigate()

    React.useEffect(() => {
        const interval = setInterval(() => {
            setIsBouncing(prev => !prev);
        }, 2000);

        return () => clearInterval(interval);
    }, []);


    return (
        <div className="w-full z-30 relative flex justify-center pb-[1000px] overflow-hidden">
            <div className="absolute  -top-[0px] left-0 w-full h-full bg-[#F7F7F7]"/>

            <div className="lg:w-[1000px] w-full lg:p-0 p-5 relative flex flex-col gap-5">
                <div className="lg:inline-block">
                    <p className="lg:text-[30px] text-[20px] lg:leading-[48.75px] leading-[20px] lg:text-left text-center font-unbounded font-medium text-[#1B3C4D] lg:pt-32 pt-5 pb-5">
                        Как это работает?
                    </p>
                    <div className="font-unbounded font-extralight text-[#1B3C4D] uppercase">
                        {/* Desktop */}
                        <p className="hidden lg:block lg:text-[60px]">
                            Загрузи своё фото,<br/>
                            и наш<br/>
                            AI про<span className="text-[#8296A6]">анализирует</span><br/>
                            твои <span className="text-[#8296A6]">черты лица</span> и определит  типаж
                        </p>
                        
                        {/* Mobile - каждая строка растягивается на всю ширину */}
                        <div className="lg:hidden text-[26px] space-y-1">
                            <div className="flex justify-between">
                            <span>Загрузи</span>
                            <span>своё</span>
                            </div>
                            <div className="flex justify-between">
                            <span>фото,</span>
                            <span>и</span>
                            <span>наш</span>
                            <span>AI</span>
                            </div>
                            <div className="flex justify-between">
                            <span>про<span className="text-[#8296A6]">анализирует</span></span>
                            </div>
                            <div className="flex justify-between">
                            <span>твои</span>
                            <span className="text-[#8296A6]">черты</span>
                            <span className="text-[#8296A6]">лица</span>
                            </div>
                            <div className="flex justify-between">
                            <span>и</span>
                            <span>определит</span>
                            </div>
                            <div>типаж</div>
                        </div>
                    </div>
                </div>
                <div className="relative w-full mt-5 flex justify-center">
                    <div className="absolute left-0 top-0">
                        <p className="lg:w-[224px] text-[#1B3C4D] w-full font-montserrat font-normal text-[12px] uppercase border-x border-[#1B3C4D] px-5 py-5 rounded-2xl text-center">
                            <span className="font-bold">В подарок</span> ты получишь мини-гайд о своем типаже
                        </p>
                    </div>
                    <div
                        className="absolute lg:top-[340px] lg:right-10 top-[650px] right-0 w-52 h-32 rounded-full backdrop-blur-md flex items-center justify-center shadow-[0_0_45px_15px_rgba(194,206,216,0.86)]"
                        style={{
                            backgroundColor: 'rgba(194, 206, 216, 0.64)',
                        }}
                    >
                        <p className="text-[#1B3C4D] text-center lg:text-[30px] text-[20px] font-regular font-unbounded -mt-5">
                            <span className="uppercase text-[10px] font-normal -ml-1 font-montserrat">стоимость</span>
                            <br />
                            <div className="lg:font-medium font-normal">
                                3990 Р
                            </div>
                        </p>
                    </div>
                    <img style={{ transitionDuration: '2000ms' }} className={`absolute transform lg:max-w-[100%] max-w-[500px] ease-in-out ${isBouncing === true ? "-rotate-10 lg:-top-[180px] top-[200px]" : "-rotate-7 lg:-top-[170px] top-[210px]"}`} src="/photos/main/Soplya2.webp" alt="" />
                    <img className="absolute w-80 top-[130px]" src="/photos/main/Mobilka.webp" alt="" />
                    <iframe
                        width="190"
                        height="220"
                        src="https://rutube.ru/play/embed/f4d76c7aebd0ac06307e736cb867db5a"
                        frameBorder="0"
                        allow="autoplay"
                        allowFullScreen
                        className="absolute top-[235px] z-30 rounded-2xl border-none"
                    />
                    <img className="absolute w-[500px] lg:top-[500px] top-[660px] lg:left-20" src="/photos/main/MiddleWoman.png" alt=""/>
                    <div className="absolute left-1/2 lg:flex hidden transform text-[11px] font-light -translate-x-1/2 top-[930px] w-[240px] h-[50px] items-center justify-center rounded-full bg-[#1B3C4D] font-unbounded text-white uppercase cursor-pointer hover:shadow-xl transition duration-200"
                         onClick={() => nav("/payment")}
                    >
                        начать сейчас
                    </div>
                </div>
            </div>
        </div>
    );
};

export default SectionWrapper(CenterFirst, 'about')