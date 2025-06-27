import React from 'react';

const Loading = () => {

    const [isBouncing, setIsBouncing] = React.useState(false);
    React.useEffect(() => {
        const interval = setInterval(() => {
            setIsBouncing(prev => !prev);
        }, 2000);

        return () => clearInterval(interval);
    }, []);


    return (
        <div className={`w-full lg:h-auto min-h-screen relative`}>
            <img src="/photos/LK/WomanLK.png" alt="" className={`absolute lg:hidden top-0 left-0 min-h-screen object-cover scale-150`} />
            <div className={`w-full h-screen absolute lg:bg-[#C2CED8]`} />
            <img src="/photos/LK/BottomBlurLK.png" alt="" className="absolute -bottom-28 left-1/2 -translate-x-1/2  w-full lg:hidden" />

            <div className="absolute lg:top-[40%] top-[55%] left-1/2 -translate-x-1/2 -translate-y-1/2 lg:h-[40%] h-[70%] lg:block flex flex-col items-center justify-between text-[#1B3C4D]">
                <div className="flex flex-col items-center justify-start h-full gap-4">
                    <p className="text-center lg:text-[#1B3C4D] text-white font-light font-montserrat uppercase ">еще пару мгновений, <br />
                        происходит магия...
                    </p>
                    <img src="/photos/LK/Krutilcka.svg" className="lg:mt-10" alt=""/>

                </div>
                <img src="/photos/main/MiddleWoman.png" className="lg:block hidden w-[65%] mx-auto" alt=""/>

            </div>

            <img style={{ transitionDuration: '2000ms' }} className={`absolute h-[750px] lg:block hidden w-auto z-20 transform ease-in-out lg:left-0 md:-left-[50%] -left-[40%] ${isBouncing ? "lg:top-[10%] -top-[20%]" : "lg:top-[5%] -top-[25%]"}`} src="/photos/main/Soplya.png" alt="" />
            <img style={{ transitionDuration: '2000ms' }} className={`absolute h-[580px] lg:block hidden z-20 lg:right-0 md:-right-[20%] -right-[50%] transform ease-in-out ${isBouncing ? "top-[0%]" : "-top-[5%]"}`} src="/photos/main/Soplya3.png" alt="" />
        </div>
    );
};

export default Loading;