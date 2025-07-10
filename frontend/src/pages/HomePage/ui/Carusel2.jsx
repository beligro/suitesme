import React from "react";
import SectionWrapper from "../../../hoc/SectionWrapper.jsx";
import Marquee from "react-fast-marquee";

const Carusel2 = () => {
    const images = Array(6).fill("/photos/main/Circulation.webp");

    return (
        <div className="w-full z-30 flex flex-col justify-center items-center lg:mt-32 -mt-7 bg-black relative overflow-x-hidden">
            <div className="w-full max-w-[1000px] z-10 lg:py-32 py-16">
                <p className="text-[25px] lg:p-0 p-5 font-unbounded font-medium text-[#C2CED8] leading-tight lg:w-2/3 w-full">
                    Присоединяйтесь к тысячам людей, которые уже нашли <span className="text-white">свой уникальный стиль</span> с SuitesMe
                </p>
            </div>

            <div className="w-full pb-32">
                <Marquee
                    speed={40}
                    gradient={false}
                    pauseOnHover={false}
                    className="w-full"
                    autoFill={true}
                >
                    {images.map((src, index) => (
                        <img
                            key={index}
                            src={src}
                            alt={`style-${index}`}
                            loading="lazy"
                            decoding="async"
                            draggable={false}
                            className="h-64 w-auto object-cover pointer-events-none select-none"
                        />
                    ))}
                </Marquee>
            </div>
        </div>
    );
};

export default SectionWrapper(Carusel2, 'examples');