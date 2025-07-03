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
        <div className="w-full z-30 relative flex justify-center pb-[900px]">
            <div className="absolute  -top-[0px] left-0 w-full h-full bg-white"/>

            <div className="lg:w-[1000px] w-full lg:p-0 p-5 relative flex flex-col gap-5">
                <p className="lg:text-[30px] text-[23px] lg:text-left text-center font-unbounded font-extrabold text-[#1B3C4D] lg:pt-32 pt-5">
                    Как это работает?
                </p>
                <p className="lg:text-[60px] text-[26px] font-unbounded font-extralight text-[#1B3C4D] uppercase">
                    Загрузи своё фото, <br/> и наш <br/>
                    AI про<span className="text-[#8296A6]">анализирует </span> твои
                    <span className="text-[#8296A6]"> черты лица </span> и определит типаж
                </p>
                <div className="relative w-full mt-5 flex justify-center">
                    <div className="absolute left-0 top-0">
                        <p className="lg:w-[200px] w-full font-montserrat font-light text-[12px] uppercase border-x border-black px-4 py-2 rounded-2xl text-center">
                            <span className="font-bold">В подарок</span> ты получишь мини-гайд о своем типаже
                        </p>
                    </div>
                    <div
                        className="absolute lg:top-80 lg:right-10 top-[600px] right-0 w-52 h-32 rounded-full backdrop-blur-md flex items-center justify-center shadow-[0_0_60px_20px_rgba(144,163,171,0.4)]"
                        style={{
                            backgroundColor: 'rgba(144, 163, 171, 0.27)',
                        }}
                    >
                        <p className="text-[#1B3C4D] text-center text-[30px] font-semibold">
                            <span className="uppercase text-[12px] font-normal -ml-1">стоимость</span>
                            <br />
                            3990 Р
                        </p>
                    </div>
                    <img style={{ transitionDuration: '2000ms' }} className={`absolute transform lg:max-w-[100%] max-w-[500px] ease-in-out ${isBouncing === true ? "-rotate-10 lg:-top-[180px] top-[200px]" : "-rotate-7 lg:-top-[170px] top-[210px]"}`} src="/photos/main/Soplya2.png" alt="" />
                    <img className="absolute w-80 top-[130px]" src="/photos/main/Mobilka.png" alt="" />
                    <iframe
                        width="190"
                        height="220"
                        src="https://rutube.ru/play/embed/f4d76c7aebd0ac06307e736cb867db5a"
                        frameBorder="0"
                        allow="autoplay"
                        allowFullScreen
                        className="absolute top-[235px] z-30 rounded-2xl border-none"
                    />
                    <img className="absolute w-[500px] lg:top-[500px] top-[660px] lg:left-20 -left-20" src="/photos/main/MiddleWoman.png" alt=""/>
                    <div className="absolute left-1/2 lg:flex hidden transform text-[12px] font-light -translate-x-1/2 top-[850px] w-[240px] h-[50px] items-center justify-center rounded-full bg-[#1B3C4D] font-unbounded text-white uppercase cursor-pointer hover:shadow-xl transition duration-200"
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