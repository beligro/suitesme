import React, {useEffect} from 'react';
import { useNavigate } from "react-router-dom";
import {MAIN, PAYMENT} from "../../../app/routes/constans.js";
import {useDispatch, useSelector} from "react-redux";
import {$authHost, $host} from "../../../app/indexAPI.js";
import {logout, setUser} from "../../../features/Auth/model/slice.js";
import {selectUser} from "../../../features/Auth/model/selector.js";

const Header = () => {
    const dispatch = useDispatch();


    const [isBouncing, setIsBouncing] = React.useState(false);
    const [isOpen, setIsOpen] = React.useState(false);
    const nav = useNavigate();
    const [step, setStep] = React.useState(4); // 0 1 2 - функциональные, 3 - загрузка
    const [style, setStyle] = React.useState("");
    const user = useSelector(selectUser);
    const [canUpload, setCanUpload] = React.useState(false);
    const [selectedFiles, setSelectedFiles] = React.useState([]);


    const handleLogout = async () => {
        const refreshToken = localStorage.getItem('refresh_token')
        try {
            if (!refreshToken) {
                dispatch(logout());
            }
            await $host.post("/auth/logout", {
                refresh_token: localStorage.getItem('refresh_token')
            });
            localStorage.removeItem("refresh_token");
            dispatch(logout());
        }catch (error) {
            console.log(error);
            throw error;
        }
    }

    //-------------------------API

    const getInfo = async () => {
        try {
            const response = await $authHost.get("style/info");
            return { status: response.status, data: response.data };
        } catch (error) {
            if (error.response) {
                return { status: error.response.status };
            } else {
                console.log("Unexpected error:", error);
                return { status: 500 };
            }
        }
    };

    const styleBuild = async (formData) => {
        try {
            const {data} = await $authHost.post("style/build", formData, {
                headers: { "Content-Type": "multipart/form-data" },
            });
            console.log(data);
            return data;
        } catch (error) {
            console.log(error);
        }
    }

    //----------------------------



    const verfication = async () => {

        try {
            const response = await getInfo();
            if (response.status === 200) {
                setStyle(response.data.style_id);
                setCanUpload(response.data.can_upload_photos);
                setStep(2);
            } else if (response.status === 404) {
                setStep(0);
                setCanUpload(response?.can_upload_photos);
            } else if (response.status === 402) {
                nav(PAYMENT);
            } else {
                nav(PAYMENT);
            }
        } catch (error) {
            if (error.response?.status === 401) {
                setTimeout(() => {
                    verfication();
                }, 200);
            } else {
                nav(PAYMENT);
            }
        }
    };

    //ФОТО----------------

    const handleFilesSelect = (files) => {
        if (!files || files.length === 0) return;

        // Calculate how many more photos can be added
        const remainingSlots = 4 - selectedFiles.length;
        const filesToAdd = Array.from(files).slice(0, remainingSlots);

        if (files.length > remainingSlots) {
            alert(`Вы можете добавить ещё только ${remainingSlots} ${remainingSlots === 1 ? 'фото' : 'фото'}`);
        }

        setSelectedFiles([...selectedFiles, ...filesToAdd]);
    };

    const removeFile = (indexToRemove) => {
        setSelectedFiles(selectedFiles.filter((_, index) => index !== indexToRemove));
    };

    const handlePhotoUpload = async () => {
        if (selectedFiles.length === 0) return;

        const formData = new FormData();
        // Append all files with the field name 'photos'
        for (let i = 0; i < selectedFiles.length; i++) {
            formData.append('photos', selectedFiles[i]);
        }

        try {
            setStep(3);

            const data = await styleBuild(formData);

            if (data?.style_id) {
                console.log('style_id получен:', data.style_id);
                setStyle(data.style_id)
                setStep(2)
                setSelectedFiles([]);
            } else {
                console.warn('style_id отсутствует в ответе:', data);
                setStep(0);
                setSelectedFiles([]);
            }
        } catch (err) {
            console.error('Ошибка при загрузке фото:', err);
            setStep(0);
            setSelectedFiles([]);
        }
    };

    const reloadInfo = async () => {
        try {
            const {data} = await getInfo()
            setCanUpload(data.can_upload_photos)
            setStyle(data.style_id)
            setStep(2);
        } catch (error) {
            console.log(error);
            setStep(0);
        }
    }

    // useEffect(() => {
    //     if (!user.first_name) {
    //         setStep(3);
    //         $authHost.get("profile/info")
    //             .then(({data}) => {
    //                 dispatch(setUser(data));
    //                 setStep(1);
    //             })
    //             .catch((error) => {
    //                 console.log(error);
    //                 setStep(0);
    //             });
    //     }
    // }, [user]);

    useEffect(() => {
        const interval = setInterval(() => {
            setIsBouncing(prev => !prev);
        }, 2000);

        return () => clearInterval(interval);
    }, []);

    useEffect(() => {
        if (isOpen) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = 'auto';
        }

        return () => {
            document.body.style.overflow = 'auto';
        };
    }, [isOpen]);

    const init = async () => {

        try {
            const [profileRes, styleRes] = await Promise.all([
                user.first_name ? null : $authHost.get('profile/info'),
                getInfo(),
            ]);
            if (profileRes) dispatch(setUser(profileRes.data));

            if (styleRes.status === 200) {
                setStyle(styleRes.data.style_id);
                setCanUpload(styleRes.data.can_upload_photos);
                setStep(2);
            } else if (styleRes.status === 404) {
                setStep( user.first_name ? 1 : 0 );
            } else if (styleRes.status === 402) {
                nav(PAYMENT);
            }    else if (styleRes.status === 403) {
                setStep(1);
            } else {
                nav(PAYMENT);
            }
        } catch (err) {
            console.log(err);
            nav(PAYMENT);
        }
    };

    useEffect(() => { init(); }, []);

    useEffect(() => {verfication()}, [])

    return (
        <div className={`w-full lg:h-auto min-h-screen relative`}>
            <img src="/photos/LK/WomanLK.png" alt="" className={`absolute lg:hidden top-0 left-0 min-h-screen ${step === 3 ? "object-cover scale-150" : "object-cover"}`} />
            <div className={`w-full h-screen absolute ${
                step === 0
                    ? "bg-[#ffffff] lg:bg-[#C2CED8] lg:opacity-100 opacity-70"
                    : step === 3
                        ? "lg:bg-[#C2CED8]"
                        : "bg-[#C2CED8]"
            }`} />

            <img src="/photos/LK/Shadow.png" alt="" className={`absolute top-0 left-0 lg:hidden ${step === 0 || step === 3 ? "hidden" : ""}`} />
            <img src="/photos/LK/BottomBlurLK.png" alt="" className="absolute -bottom-28 left-1/2 -translate-x-1/2  w-full lg:hidden" />

            <div className={`lg:backdrop-blur-none backdrop-blur-sm z-30 w-full lg:h-[100px] h-[60px] absolute top-0 left-0 flex flex-row items-center justify-between lg:px-20 px-5 ${
                step === 0
                    ? "bg-gradient-to-t lg:to-[#00000040] to-[#00000030] from-[#C2CED8]"
                    : "bg-gradient-to-t lg:to-[#00000060] to-[#00000060] from-[#C2CED8]"
            }`}>
                <img src="/photos/main/Profile.svg" className="h-[20px] lg:hidden block cursor-pointer" alt=""/>
                <p className="font-headingnowtrial text-[#FFFFFF] cursor-pointer" onClick={() => nav(MAIN)}>MNEIDET</p>
                <img src="/photos/main/Burger.svg" className="h-[20px] lg:hidden block cursor-pointer" alt="" onClick={() => setIsOpen(!isOpen)} />
                <div className="lg:flex flex-row xl:gap-[45px] gap-[25px] items-center justify-end hidden">
                    <button className="px-7 h-12 flex items-center justify-center rounded-full !border text-[11px] !border-white font-light uppercase text-white font-unbounded cursor-pointer" onClick={() => handleLogout()}>Выйти</button>
                </div>
            </div>

            {step === 0 && (
                <div className="absolute top-[55%] left-1/2 -translate-x-1/2 -translate-y-1/2 lg:h-[80%] h-[70%] lg:block flex flex-col items-center justify-between text-[#1B3C4D]">
                    <div className="flex flex-col items-center lg:justify-around justify-start h-full gap-4">
                        <p className="lg:text-[30px] text-[23px] font-unbounded font-extralight text-center uppercase lg:mb-4 mb-4">Добро пожаловать в <br className="lg:block hidden" /> SUITSME.AI</p>

                        {selectedFiles.length === 0 ? (
                            <div className="relative w-[35%] min-w-[200px] lg:border-none border border-[#607E96] py-12 backdrop-blur-sm flex flex-col items-center justify-center rounded-xl bg-[#FFFFFF6E] gap-6 cursor-pointer hover:scale-95 transition duration-200 easy-in-out">
                                <input
                                    type="file"
                                    accept="image/*"
                                    multiple
                                    onChange={ (e) => {
                                        if (e.target.files && e.target.files.length > 0) {
                                            handleFilesSelect(e.target.files);
                                        }
                                    }}
                                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-50"
                                />
                                <img className="w-[15%]" src="/photos/LK/Plus.svg" alt="" />
                                <p className="uppercase text-[#1B3C4D] text-[14px] font-unbounded font-light text-center">Загрузите<br/> 1-4 фото<br/> (селфи)</p>
                            </div>
                        ) : (
                            <div className="w-full max-w-[600px] flex flex-col items-center gap-4">
                                <div className="flex flex-wrap gap-3 justify-center items-center">
                                    {selectedFiles.map((file, index) => (
                                        <div key={index} className="relative w-32 h-32 border-2 border-[#1B3C4D] rounded-lg overflow-hidden group">
                                            <img 
                                                src={URL.createObjectURL(file)} 
                                                alt={`Preview ${index + 1}`}
                                                className="w-full h-full object-cover"
                                            />
                                            <button
                                                onClick={() => removeFile(index)}
                                                className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                                            >
                                                ×
                                            </button>
                                        </div>
                                    ))}
                                    
                                    {selectedFiles.length < 4 && (
                                        <div className="relative w-32 h-32 border-2 border-dashed border-[#1B3C4D] rounded-lg flex items-center justify-center cursor-pointer hover:bg-[#FFFFFF6E] transition">
                                            <input
                                                type="file"
                                                accept="image/*"
                                                multiple
                                                onChange={ (e) => {
                                                    if (e.target.files && e.target.files.length > 0) {
                                                        handleFilesSelect(e.target.files);
                                                    }
                                                    e.target.value = '';
                                                }}
                                                className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-50"
                                            />
                                            <span className="text-3xl text-[#1B3C4D]">+</span>
                                        </div>
                                    )}
                                </div>
                                
                                <p className="text-sm font-montserrat text-[#1B3C4D]">
                                    {selectedFiles.length} из 4 {selectedFiles.length === 1 ? 'фото' : 'фото'} выбрано
                                </p>
                                <div className="flex gap-3">
                                    <button
                                        onClick={handlePhotoUpload}
                                        className="px-8 py-3 bg-[#1B3C4D] text-white rounded-full font-unbounded text-sm uppercase hover:scale-95 transition"
                                    >
                                        Отправить
                                    </button>
                                    <button
                                        onClick={() => setSelectedFiles([])}
                                        className="px-8 py-3 border border-[#1B3C4D] text-[#1B3C4D] rounded-full font-unbounded text-sm uppercase hover:scale-95 transition"
                                    >
                                        Очистить
                                    </button>
                                </div>
                            </div>
                        )}

                        <p className="text-center font-montserrat font-light text-[12px] uppercase text-[#1B3C4D]">
                            наш <span className="">AI</span> проанализирует черты лица <br className="lg:block hidden" />
                            и определит типаж
                        </p>
                        {selectedFiles.length === 0 && <img src="/photos/main/MiddleWoman.png" className="lg:block hidden w-[65%]" alt="" />}
                    </div>
                    {/*<div className="uppercase font-light text-center text-[13px] lg:hidden block">*/}
                    {/*    Здесь может быть размещен*/}
                    {/*    какой-то текст*/}
                    {/*</div>*/}
                </div>
            )}

            {step === 1 && (
                <div className="absolute top-[55%] left-1/2 -translate-x-1/2 -translate-y-1/2 lg:h-[80%] h-[70%] lg:block flex flex-col items-center justify-between text-[#1B3C4D]">
                    <div className="flex flex-col items-center lg:justify-around justify-start h-full gap-4">
                        <p className="lg:text-[30px] text-[23px] font-unbounded font-extralight text-center uppercase" >Готово! <br className="lg:hidden" /> Ваш типаж <br className="lg:block hidden" /> SUITSME.AI</p>
                        <div className="flex flex-col items-center justify-center gap-2 mb-8">
                            <div
                                className="w-10 h-10 border rounded-full border-white flex items-center justify-center cursor-pointer">
                                <img src="/photos/main/Profile.svg" className="w-4" alt="" />
                            </div>
                            <p className="text-center font-montserrat font-normal text-[14px] cursor-pointer">{user.first_name}</p>
                        </div>

                        <img src="/photos/LK/Step1.png" className="lg:w-[17%] w-[70%] max-w-[150px] cursor-pointer hover:scale-95 transition ease-in-out duration-200" alt="" onClick={() => reloadInfo()}/>
                        <p className="text-center font-montserrat font-light text-[12px] uppercase">
                            нажмите на иконку,  чтобы НАЧАТЬ <br className="lg:block hidden"/> ТИПИРОВАНИЕ
                        </p>
                        <img src="/photos/main/MiddleWoman.png" className="lg:block hidden w-[65%]" alt=""/>
                    </div>

                </div>
            )}

            {step === 2 && (
                <div className="absolute top-[55%] left-1/2 -translate-x-1/2 -translate-y-1/2 lg:h-[80%] h-[70%] lg:block flex flex-col items-center justify-between text-[#1B3C4D]">
                    <div className="flex flex-col items-center lg:justify-around justify-start h-full gap-4">
                        <p className="lg:text-[30px] text-[23px] font-unbounded font-extralight text-center uppercase" >Готово! <br className="lg:hidden" /> Ваш типаж <br className="lg:block hidden" /> SUITSME.AI</p>
                        <div className="flex flex-col items-center justify-center gap-2 mb-8">
                            <div
                                className="w-10 h-10 border rounded-full border-white flex items-center justify-center cursor-pointer">
                                <img src="/photos/main/Profile.svg" className="w-4" alt="" />
                            </div>
                            <p className="text-center font-montserrat font-normal text-[14px] cursor-pointer">{user.first_name}</p>
                        </div>
                        {canUpload && (<button className="w-32 h-10 border border-white rounded-xl hover:bg-white/50 transition duration-200" onClick={() => setStep(0)}>Повторить</button>)}
                        <p className="text-center font-montserrat text-[25px]">Ваш типаж - <span className="font-semibold ">{style}</span></p>
                        <img src="/photos/main/MiddleWoman.png" className="lg:block hidden w-[65%]" alt=""/>
                    </div>
                </div>
            )}

            {/*{step === 2 && (*/}
            {/*    <div className="absolute top-[55%] left-1/2 -translate-x-1/2 -translate-y-1/2 lg:h-[80%] h-[70%] lg:block flex flex-col items-center justify-between text-[#1B3C4D]">*/}
            {/*        <div className="flex flex-col items-center lg:justify-around justify-start h-full gap-4">*/}
            {/*            <p className="lg:text-[30px] text-[23px] font-unbounded font-extralight text-center uppercase" >Добро пожаловать в <br className="lg:block hidden" /> SUITSME.AI</p>*/}
            {/*            <div className="flex flex-col items-center justify-center gap-2">*/}
            {/*                <div*/}
            {/*                    className="w-10 h-10 border rounded-full border-white flex items-center justify-center cursor-pointer">*/}
            {/*                    <img src="/photos/main/Profile.svg" className="w-4" alt="" />*/}
            {/*                </div>*/}
            {/*                <p className="text-center font-montserrat font-normal text-[14px] cursor-pointer">Имя</p>*/}
            {/*            </div>*/}
            {/*            <p className="text-center font-montserrat font-light lg:text-[12px] text-[10px]  uppercase">ВАШ ТИПАЖ</p>*/}
            {/*            <img src="/photos/LK/Step2.png" className="lg:w-[17%] w-[70%] max-w-[150px] cursor-pointer hover:scale-95 transition ease-in-out duration-200" alt="" onClick={() => setStep(0)}/>*/}
            {/*            <p className="text-center font-montserrat font-light text-[12px] uppercase">*/}
            {/*                нажмите на иконку, чтобы посмотреть <br className="lg:block hidden"/> результат*/}
            {/*            </p>*/}
            {/*            <img src="/photos/main/MiddleWoman.png" className="lg:block hidden w-[65%]" alt=""/>*/}
            {/*        </div>*/}
            {/*        <div className="uppercase font-light text-center text-[13px] lg:hidden block">*/}
            {/*            Здесь может быть размещен*/}
            {/*            какой-то текст*/}
            {/*        </div>*/}
            {/*    </div>*/}
            {/*)}*/}


            {step === 3 && (
                <div className="absolute lg:top-[40%] top-[55%] left-1/2 -translate-x-1/2 -translate-y-1/2 lg:h-[40%] h-[70%] lg:block flex flex-col items-center justify-between text-[#1B3C4D]">
                    <div className="flex flex-col items-center justify-start h-full gap-4">
                        <p className="text-center lg:text-[#1B3C4D] text-white font-light font-montserrat uppercase ">еще пару мгновений, <br />
                            происходит магия...
                        </p>
                        <img src="/photos/LK/Krutilcka.svg" className="lg:mt-10" alt=""/>

                    </div>
                    <img src="/photos/main/MiddleWoman.png" className="lg:block hidden w-[65%] mx-auto" alt=""/>

                </div>
            )}

            {step === 4 && (
                <div className="absolute lg:top-[40%] top-[55%] left-1/2 -translate-x-1/2 -translate-y-1/2 lg:h-[40%] h-[70%] lg:block flex flex-col items-center justify-between text-[#1B3C4D]">

                </div>
            )}

            <img style={{ transitionDuration: '2000ms' }} className={`absolute h-[750px] lg:block hidden w-auto z-20 transform ease-in-out lg:left-0 md:-left-[50%] -left-[40%] ${isBouncing ? "lg:top-[10%] -top-[20%]" : "lg:top-[5%] -top-[25%]"}`} src="/photos/main/Soplya.webp" alt="" />
            <img style={{ transitionDuration: '2000ms' }} className={`absolute h-[580px] lg:block hidden z-20 lg:right-0 md:-right-[20%] -right-[50%] transform ease-in-out ${isBouncing ? "top-[0%]" : "-top-[5%]"}`} src="/photos/main/Soplya3.webp" alt="" />
            <div className={`${isOpen ? "flex" : "hidden"} w-full z-50 absolute top-0 left-0 flex-col bg-[rgb(130,148,155)] h-full`}>
                <div className="w-full flex mt-5">
                    <p className="font-headingnowtrial text-[#FFFFFF] cursor-pointer" onClick={() => nav(MAIN)}>MNEIDET</p>
                    <img src="/photos/main/cross-svgrepo-com.svg" alt="" className="absolute right-5 top-3 w-[36px] cursor-pointer" onClick={() => setIsOpen(!isOpen)} />
                </div>
                <div className="w-full flex flex-col items-center justify-center h-full gap-14">
                    <div
                        onClick={() => handleLogout()}
                        className="flex w-full flex-col gap-3 items-center justify-center">
                        <div className="w-12 h-12 border rounded-full border-white flex items-center justify-center cursor-pointer" >
                            <img src="/photos/main/Profile.svg" className="w-6" alt="" />
                        </div>
                        <p className="text-center font-montserrat font-light text-[16px] text-white cursor-pointer" >Выйти</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Header;