import React, { useState, useEffect } from "react";
import { Swiper, SwiperSlide } from "swiper/react";
import { Navigation, Pagination } from "swiper/modules";
import "swiper/css";
import "swiper/css/navigation";
import "swiper/css/pagination";
import "../../../index.css";

const clients = [
    "photos/main/womans/Woman1.png",
    "photos/main/womans/Woman2.png",
    "photos/main/womans/Woman3.png",
    "photos/main/womans/Woman4.png",
];

const Carusel = () => {
    const [modalOpen, setModalOpen] = useState(false);
    const [activeClientIndex, setActiveClientIndex] = useState(null);

    useEffect(() => {
        document.body.style.overflow = modalOpen ? 'hidden' : 'auto';
        return () => {
            document.body.style.overflow = 'auto';
        };
    }, [modalOpen]);

    return (
        <div className="w-full flex justify-center lg:mt-32 mt-10 pl-4 relative">
            <img src="/photos/main/Lines.png" alt="" className="w-full absolute bottom-0 z-0 lg:block hidden" />
            <div className="w-full lg:w-[1000px] z-10 ">
                <p className="lg:hidden text-[23px] text-center font-unbounded font-extrabold text-[#1B3C4D] pb-10">
                    Как это работает?
                </p>
                <p className="text-[30px] lg:text-[53px] text-center font-unbounded lg:text-left text-balance w-full font-extralight uppercase text-[#1B3C4D] leading-tight">
                    Клиенты, которые уже работают по системе{" "}
                    <span className="text-[#8296A6] font-extralight">MNE IDET</span>
                </p>

                <p className="lg:text-[16px] text-[12px] text-center text-[#1B3C4D] font-normal uppercase pt-10 lg:w-auto w-[60%] lg:text-left ">
                    Нажмите на фото,<br className="lg:hidden" /> чтобы посмотреть кейс
                </p>

                <div className="mt-10 relative pb-24">
                    <Swiper
                        modules={[Navigation, Pagination]}
                        loop={true}
                        spaceBetween={20}
                        slidesPerView={4}
                        navigation={{
                            nextEl: ".swiper-next",
                            prevEl: ".swiper-prev",
                        }}
                        pagination={{
                            el: ".custom-swiper-pagination",
                            clickable: true,
                            renderBullet: (index, className) => {
                                return `<span class="${className}"></span>`;
                            },
                        }}
                        breakpoints={{
                            320: { slidesPerView: 1.2 },
                            640: { slidesPerView: 2 },
                            1024: { slidesPerView: 3 },
                            1280: { slidesPerView: 4 },
                        }}
                    >
                        {clients.map((src, index) => (
                            <SwiperSlide key={index}>
                                <img
                                    src={src}
                                    alt={`client-${index}`}
                                    className="rounded-3xl w-full h-[400px] object-cover hover:scale-95 transition duration-200 cursor-pointer"
                                    onClick={() => {
                                        setModalOpen(true);
                                        setActiveClientIndex(index);
                                    }}
                                />
                            </SwiperSlide>
                        ))}
                    </Swiper>

                    <div className="swiper-next absolute lg:-right-20 right-6 -top-20 lg:top-[45%] lg:-translate-y-1/2 z-10 lg:w-16 w-10 lg:h-16 h-10 flex items-center justify-center cursor-pointer bg-white">
                        <img className="w-full" src="/photos/main/NextButton.png" alt="" />
                    </div>

                    <div className="custom-swiper-pagination swiper-pagination lg:ml-[40%] ml-[18%]" />

                </div>

                <div className="w-full flex justify-center lg:mt-32 mt-10 pb-5">
                    <div className="w-[240px] h-[50px] text-[14px] font-light flex items-center justify-center rounded-full bg-[#1B3C4D] text-white uppercase cursor-pointer hover:shadow-xl transition duration-200">
                        узнать свой типаж
                    </div>
                </div>
            </div>

            {modalOpen && activeClientIndex !== null && (
                <div className="fixed inset-0 z-50 bg-black bg-opacity-80 flex items-center justify-center">
                    <div className="relative w-full h-full flex items-center justify-center">
                        <Swiper
                            modules={[Navigation]}
                            navigation={{
                                nextEl: ".custom-next",
                                prevEl: ".custom-prev",
                            }}
                            loop
                            className="w-[90%] max-w-[1000px]"
                        >
                            {["before", "after"].map((type) =>
                                [1, 2, 3].map((i) => (
                                    <SwiperSlide key={`${type}-${i}`}>
                                        <div className="relative max-h-[90vh] flex justify-center">
                                            <div className="relative">
                                                <img
                                                    src={`/photos/main/womans/woman${activeClientIndex + 1}/hero${type === 'before' ? 'Before' : 'After'}${i}.png`}
                                                    className="object-contain w-full max-h-[90vh] mx-auto rounded-2xl"
                                                    alt=""
                                                />
                                                <div className="custom-prev absolute left-2 top-1/2 -translate-y-1/2 z-50 cursor-pointer backdrop-blur-2xl rounded-full">
                                                    <img src="/photos/main/LeftButtonOpenSlider.svg" alt="prev" className="w-10 h-10" />
                                                </div>
                                                <div className="custom-next absolute right-2 top-1/2 -translate-y-1/2 z-50 cursor-pointer backdrop-blur-2xl rounded-full">
                                                    <img src="/photos/main/RightButtonOpenSlider.svg" alt="next" className="w-10 h-10" />
                                                </div>
                                                <p className="absolute font-montserrat top-2 left-2 text-white px-2 py-1 text-sm rounded ">
                                                    {type === "before" ? "ДО" : "ПОСЛЕ"}
                                                </p>
                                                <button
                                                    onClick={() => setModalOpen(false)}
                                                    className="absolute top-2 right-2 text-white text-2xl w-8 h-8 rounded-full flex items-center justify-center"
                                                >
                                                    <img src="/photos/main/cross-svgrepo-com.svg" alt="close" />
                                                </button>
                                            </div>
                                        </div>
                                    </SwiperSlide>
                                ))
                            )}
                        </Swiper>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Carusel;