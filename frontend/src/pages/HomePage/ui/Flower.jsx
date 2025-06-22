import React from 'react';
import {useNavigate} from "react-router-dom";

const Flower = () => {

    const nav = useNavigate()

    return (
        <div
            className="w-full h-[700px] relative"
            style={{
                backgroundImage: `radial-gradient(ellipse at bottom center, #C2CED8 0%, transparent 70%)`,
                backgroundRepeat: 'no-repeat',
                backgroundSize: '100% 100%',
            }}
        >
            <img src="/photos/main/Flower.png" alt="" className="absolute z-10 top-[14%] h-[150%] left-[10%] object-contain" />

            <div className="z-20 relative w-full flex flex-col items-center justify-center">
                <p className="font-unbounded font-semibold text-center text-[30px] mt-20">
                    Готова узнать,<br/>
                    что действительно тебе идет?
                </p>

                <p className="font-montserrat text-[12px] uppercase font-light text-center lg:mt-20 mt-5">оформи прямо сейчас и получи скидку 50%</p>

                <div className="md:w-[500px] w-full backdrop-blur-2xl flex flex-row sm:gap-20 gap-10 sm:p-12 p-5 items-center justify-center mt-4 rounded-2xl ">
                    <p className="font-unbounded text-[30px]">3990 ₽</p>
                    <p className="font-unbounded text-[30px] line-through">7980 ₽</p>
                </div>
                <div className="w-full flex justify-center mt-32 pb-5">
                    <div className="w-[240px] h-[50px] text-[14px] font-light flex items-center justify-center rounded-full bg-[#1B3C4D] text-white uppercase cursor-pointer hover:shadow-xl transition duration-200"
                         onClick={() => nav("/LK")}
                    >
                        начать анализ
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Flower;