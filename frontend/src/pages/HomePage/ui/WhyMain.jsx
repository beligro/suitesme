import React from 'react';
import SectionWrapper from "../../../hoc/SectionWrapper.jsx";
import {useNavigate} from "react-router-dom";

const WhyMain = () => {

    const nav = useNavigate()


    return (
        <div className="w-full flex justify-center bg-[#F7F7F7] mt-10">
            <div className="lg:w-[1000px] w-full p-5 flex flex-col gap-5 ">
                <p className="lg:text-[30px] text-[23px] font-bold lg:text-left text-center font-unbounded text-[#1B3C4D] lg:mb-0 mb-10 lg:pt-32 pt-0">
                    Почему стоит выбирать <br/>
                    MNE IDET?
                </p>
                <div className="w-full flex flex-col lg:gap-[10px] gap-[5px] bg-[#90A3AB]/37 shadow-[0_0_60px_20px_rgba(144,163,171,0.5)]" style={{ backgroundColor: 'rgba(144, 163, 171, 0.37)' }}>
                    <div className="w-full rounded-xl h-[109px] bg-white flex lg:items-center items-start lg:pt-0 pt-4 justify-between lg:px-10 pl-6 pr-5 ">
                        <p className="uppercase lg:text-[16px] text-[17px] font-light lg:text-black text-[#8296A6] lg:pr-0 pr-7 font-montserrat"> <span className="lg:text-[#8296A6] lg:font-medium">Индивидуальность </span> вместо трендов и шаблонов</p>
                        <img className="lg:w-5 w-3 lg:pt-0 pt-14" src="/photos/main/Subtract.svg" alt="" />
                    </div>
                    <div className="w-full rounded-xl h-[109px] bg-white flex lg:items-center items-start lg:pt-0 pt-4 justify-between lg:px-10 pl-6 pr-5">
                        <p className="uppercase lg:text-[16px] text-[17px] font-light lg:text-black text-[#8296A6] lg:pr-0 pr-7 font-montserrat"> Акцент на <span className="lg:text-[#8296A6] lg:font-medium"> природных </span> достоинствах </p>
                        <img className="lg:w-5 w-3 lg:pt-0 pt-14" src="/photos/main/Subtract.svg" alt="" />
                    </div>
                    <div className="w-full rounded-xl h-[109px] bg-white flex lg:items-center items-start lg:pt-0 pt-4 justify-between lg:px-10 pl-6 pr-5">
                        <p className="uppercase lg:text-[16px] text-[17px] font-light lg:text-black text-[#8296A6] lg:pr-0 pr-7 font-montserrat"> <span className="lg:text-[#8296A6] lg:font-medium"> Экономия </span> времени и денег </p>
                        <img className="lg:w-5 w-3 lg:pt-0 pt-14" src="/photos/main/Subtract.svg" alt="" />
                    </div>
                    <div className="w-full rounded-xl h-[109px] bg-white flex lg:items-center items-start lg:pt-0 pt-4 justify-between lg:px-10 pl-6 pr-5">
                        <p className="uppercase lg:text-[16px] text-[17px] font-light lg:text-black text-[#8296A6] lg:pr-0 pr-7 font-montserrat"> Легкий и <span className="lg:text-[#8296A6] lg:font-medium"> эффективный </span> шоппинг </p>
                        <img className="lg:w-5 w-3 lg:pt-0 pt-14" src="/photos/main/Subtract.svg" alt="" />
                    </div>
                </div>
                <div className="w-full flex justify-center lg:mt-40 mt-16">
                    <div className="w-[240px] h-[50px] text-[12px] font-light flex items-center justify-center rounded-full bg-[#1B3C4D] font-unbounded text-white uppercase cursor-pointer hover:shadow-xl transition duration-200"
                         onClick={() => nav("/payment")}
                    >
                        узнать свой типаж
                    </div>
                </div>
            </div>
        </div>
    );
};

export default SectionWrapper(WhyMain , 'why-main');