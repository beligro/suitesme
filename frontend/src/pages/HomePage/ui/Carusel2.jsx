import React from 'react';
import SectionWrapper from "../../../hoc/SectionWrapper.jsx";

const Carusel2 = () => {
    return (
        <div className="w-full z-30 flex flex-col justify-center items-center lg:mt-32 -mt-7 bg-black overflow-hidden relative">
            <div className="w-full max-w-[1000px] z-10 lg:py-32 py-16">
                <p className="text-[25px] lg:p-0 p-5 font-unbounded font-medium text-[#C2CED8] leading-tight lg:w-2/3 w-full">
                    Присоединяйтесь к тысячам людей,
                    которые уже нашли <span className="text-white">свой уникальный
                    стиль</span> с SuitesMe
                </p>
            </div>

            <div className="w-full pb-32 overflow-hidden relative">
                <div className="flex w-max">
                    <div
                        className="flex"
                        style={{
                            animation: 'scrollLeft 30s linear infinite',
                        }}
                    >
                        {[1, 2, 3, 4, 5, 6].map((n) => (
                            <img
                                key={`img-${n}`}
                                className="h-80 w-auto object-cover"
                                src="/photos/main/Circulation.png"
                                alt="Fashion style"
                                loading="lazy"
                            />
                        ))}
                    </div>
                    <div
                        className="flex"
                        style={{
                            animation: 'scrollLeft 30s linear infinite',
                        }}
                    >
                        {[1, 2, 3, 4, 5, 6].map((n) => (
                            <img
                                key={`img-clone-${n}`}
                                className="h-80 w-auto object-cover"
                                src="/photos/main/Circulation.png"
                                alt="Fashion style"
                                loading="lazy"
                            />
                        ))}
                    </div>
                </div>
            </div>

            <style>{`
                @keyframes scrollLeft {
                    0% {
                        transform: translateX(0);
                    }
                    100% {
                        transform: translateX(-50%);
                    }
                }
            `}</style>
        </div>
    );
};

export default SectionWrapper(Carusel2, 'examples');