import React, {useMemo} from 'react';
import SectionWrapper from "../../../hoc/SectionWrapper.jsx";

const Carusel2 = () => {
    const carouselItems = useMemo(() => Array(6).fill(null), []);
    const carouselGroups = useMemo(() => Array(2).fill(null), []);

    return (
        <div className="w-full z-30 flex flex-col justify-center items-center lg:mt-32 -mt-7 bg-black relative overflow-x-hidden">
            <div className="w-full max-w-[1000px] z-10 lg:py-32 py-16">
                <p className="text-[25px] lg:p-0 p-5 font-unbounded font-medium text-[#C2CED8] leading-tight lg:w-2/3 w-full">
                    Присоединяйтесь к тысячам людей,
                    которые уже нашли <span className="text-white">свой уникальный
          стиль</span> с SuitesMe
                </p>
            </div>

            <div className="w-full pb-32 relative">
                <div className="flex w-max">
                    {carouselGroups.map((_, groupIndex) => (
                        <div
                            key={`carousel-group-${groupIndex}`}
                            className="flex"
                            style={{
                                animation: 'scrollLeft 30s linear infinite',
                                willChange: 'transform',
                            }}
                        >
                            {carouselItems.map((_, itemIndex) => (
                                <img
                                    key={`img-${groupIndex}-${itemIndex}`}
                                    className="h-80 w-auto object-cover"
                                    src="/photos/main/Circulation.webp"
                                    alt="Пример стиля от SuitesMe"
                                    loading="lazy"
                                    decoding="async"
                                    draggable="false"
                                />
                            ))}
                        </div>
                    ))}
                </div>
            </div>

            {/* GPU-friendly keyframes */}
            <style>
                {`
          @keyframes scrollLeft {
            from {
              transform: translate3d(0, 0, 0);
            }
            to {
              transform: translate3d(-50%, 0, 0);
            }
          }

          /* Respect user preference for reduced motion */
          @media (prefers-reduced-motion: reduce) {
            [style*='scrollLeft'] {
              animation: none !important;
            }
          }
        `}
            </style>
        </div>
    );
};

export default SectionWrapper(Carusel2, 'examples');