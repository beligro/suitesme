import React from 'react';
import TopMain from "./ui/TopMain.jsx";
import CenterFirst from "./ui/CenterFirst.jsx";
import WhyMain from "./ui/WhyMain.jsx";
import Carusel from "./ui/Carusel.jsx";
import Qwestions from "./ui/Questions.jsx";
import Carusel2 from "./ui/Carusel2.jsx";
import Flower from "./ui/Flower.jsx";
import Footer from "./ui/Footer.jsx";

const HomePage = () => {
    return (
        <div className="overflow-x-hidden">
            <TopMain />
            <CenterFirst />
            <WhyMain />
            <Carusel />
            <Qwestions />
            <Carusel2 />
            <Flower />
            <div className="w-full h-auto z-30"> <Footer /> </div>
        </div>
    );
};

export default HomePage;