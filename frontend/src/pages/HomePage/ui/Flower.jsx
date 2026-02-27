import React, { useState, useEffect } from 'react';
import {useNavigate} from "react-router-dom";
import { getPublicSettings } from "../../../app/settingsAPI.js";

const Flower = () => {
    const nav = useNavigate();
    const [price, setPrice] = useState("5990");
    const [oldPrice, setOldPrice] = useState(null);

    useEffect(() => {
        const fetchSettings = async () => {
            const settings = await getPublicSettings();
            if (settings.price) setPrice(settings.price);
            if (settings.old_price) setOldPrice(settings.old_price);
        };
        fetchSettings();
    }, []);

    return (
        <div
            className="w-full h-[700px] relative overflow-hidden"
            style={{
                backgroundImage: `radial-gradient(ellipse at bottom center, #C2CED8 0%, transparent 70%)`,
                backgroundRepeat: 'no-repeat',
                backgroundSize: '100% 100%',
            }}
        >
            <img src="/photos/main/Flower.webp" alt="" className="absolute z-10 top-[14%] h-[150%] left-[10%] object-contain sm:scale-100 scale-[2.5]" />

            <div className="z-20 relative w-full flex flex-col items-center justify-center lg:px-0 px-3">
                <p className="font-unbounded font-medium text-center lg:text-[30px] text-[25px] mt-20 text-[#1B3C4D]">
                    Готова узнать, <br className="lg:block hidden"/>
                    что действительно тебе идет?
                </p>

                {/* <p className="font-montserrat text-[10px] uppercase font-regular text-center lg:mt-20 mt-5 text-[#1B3C4D]">оформи прямо сейчас и получи скидку 50%</p> */}

                <div className="md:w-[500px] backdrop-blur-lg bg-white/20 flex flex-row sm:gap-20 gap-12 sm:p-12 p-12 py-10 items-center justify-center mt-4 rounded-2xl ">
                    <p className="font-unbounded lg:text-[30px] text-[20px] whitespace-nowrap text-[#1B3C4D]">{price} ₽</p>
                    {oldPrice && (
                        <p className="font-unbounded lg:text-[30px] text-[20px] line-through whitespace-nowrap text-[#1B3C4D]">{oldPrice} ₽</p>
                    )}
                </div>
                <div className="w-full flex justify-center mt-24 pb-5">
                    <div className="w-[240px] h-[50px] text-[12px] font-light font-unbounded flex items-center justify-center rounded-full bg-[#1B3C4D] text-white uppercase cursor-pointer hover:shadow-xl transition duration-200"
                         onClick={() => nav("/payment")}
                    >
                        начать анализ
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Flower;