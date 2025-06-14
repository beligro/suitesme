import React from 'react';
import SectionWrapper from "../../../hoc/SectionWrapper.jsx";

const Carusel2 = () => {
    return (
        <div className="w-full flex flex-col justify-center items-center lg:mt-32 -mt-7 bg-black overflow-hidden">
            <div className="w-full max-w-[1000px] z-10 py-32">
                <p className="text-[25px] lg:p-0 p-5 font-unbounded font-medium text-white leading-tight lg:w-2/3 w-full">
                    Присоединяйтесь к тысячам людей,
                    которые уже нашли <span className="text-[#C2CED8]">свой уникальный
                    стиль</span> с SuitesMe
                </p>
            </div>

            <div className="w-full pb-32 overflow-hidden">
                <div
                    className="flex"
                    style={{
                        width: '200%',
                        animation: 'scrollLeft 30s linear infinite',
                    }}
                >
                    {[1, 2, 3].map((n) => (
                        <img
                            key={`a-${n}`}
                            className="h-80 lg:w-[100vw] w-[120vw] object-cover"
                            src="/photos/main/Circulation.png"
                            alt=""
                        />
                    ))}
                    {[1, 2, 3].map((n) => (
                        <img
                            key={`b-${n}`}
                            className="lg:h-80 lg:w-[100vw] h-auto object-cover"
                            src="/photos/main/Circulation.png"
                            alt=""
                        />
                    ))}
                </div>
            </div>

            <style>{`
        @keyframes scrollLeft {
          0% {
            transform: translateX(0%);
          }
          100% {
            transform: translateX(-50%);
          }
        }
      `}</style>
        </div>
    );
};

export default SectionWrapper(Carusel2 , 'examples');