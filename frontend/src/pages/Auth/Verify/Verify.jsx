import React, {useEffect, useRef, useState} from 'react';
import {useNavigate} from "react-router-dom";
import {$host} from "../../../app/indexAPI.js";
import {MAIN, VERIFY} from "../../../app/routes/constans.js";



const Verify = () => {

    const [step, setStep] = React.useState(1);
    const nav = useNavigate()
    const [timer, setTimer] = useState(40);
    const timerRef = useRef(null);
    const userId = localStorage.getItem("userId");
    const [resetToken, setResetToken] = React.useState("");
    const userInfo = JSON.parse(localStorage.getItem("infoToResent"))


    const startTimer = (sec = 40) => {
        clearInterval(timerRef.current);
        setTimer(sec);
        timerRef.current = setInterval(() => {
            setTimer((t) => {
                if (t <= 1) {
                    clearInterval(timerRef.current);
                    return 0;
                }
                return t - 1;
            });
        }, 1000);
    };

    const fetchRegister = async (data) => {
        const response = await $host.post(`/auth/register`, data);
        return response.data;
    };

    const ResentCode = async (userInfo) => {
        try {
            const data = await fetchRegister(userInfo);

            localStorage.setItem('userId' , String(data.user_id))
        } catch (error) {
            console.error("Ошибка регистрации:", error);
        }
    };

    useEffect(() => {
        if (step === 1) startTimer(40);
        return () => clearInterval(timerRef.current);
    }, [step]);

    const CODE_LENGTH = 6;
    const [code, setCode] = useState(Array(CODE_LENGTH).fill(""));
    const inputRefs = useRef([]);

    const handleCodeChange = (e, idx) => {
        const raw = e.target.value.replace(/\D/g, ""); // Оставляем только цифры
        if (!raw) {
            updateDigit("", idx);
            return;
        }

        const chars = raw.split("");
        let i = idx;

        chars.forEach((char) => {
            if (i < CODE_LENGTH) {
                updateDigit(char, i);
                i++;
            }
        });

        if (i < CODE_LENGTH) {
            inputRefs.current[i]?.focus();
        } else {
            inputRefs.current[CODE_LENGTH - 1]?.blur();
        }
    };

    const handleKeyDown = (e, idx) => {
        if (e.key === "Backspace") {
            if (code[idx]) {
                updateDigit("", idx);
            } else if (idx > 0) {
                updateDigit("", idx - 1);
                inputRefs.current[idx - 1]?.focus();
            }
            e.preventDefault();
        }

        if (e.key === "ArrowLeft" && idx > 0) {
            inputRefs.current[idx - 1]?.focus();
            e.preventDefault();
        }

        if (e.key === "ArrowRight" && idx < CODE_LENGTH - 1) {
            inputRefs.current[idx + 1]?.focus();
            e.preventDefault();
        }
    };

    const updateDigit = (digit, idx) => {
        setCode((prev) => {
            const copy = [...prev];
            copy[idx] = digit;
            return copy;
        });
    };

    const sendCode = async () => {
        const token = code.join("");
        if (token.length !== 6) return alert("Введите 6-значный код");

        try {
            await $host.post("/auth/verify_email", {
                user_id: userId,
                verification_code: token,
            });
            setResetToken(token);
            setStep(3);
        } catch (e) {
            alert(e.response?.data?.message ?? "Ошибка верфикации");
        }
    };


    return (
        <div className="w-full min-h-screen flex justify-center items-center">
            {step === 1 && (
                <div className="w-full min-h-screen flex justify-center items-center">
                    <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                        <div className="w-full h-full flex flex-col justify-between gap-10">
                            <div className="w-full flex flex-col gap-10 relative">
                                <div className="md:hidden flex flex-row items-center justify-between w-full">
                                    <img src="/photos/Auth/Back.svg" alt="" className="cursor-pointer w-10" onClick={() => {nav(-1)}}/>
                                    <img src="/photos/Auth/Star.svg" alt="" className="w-10" />
                                </div>

                                <img className="md:block hidden absolute -left-20 cursor-pointer" src="/photos/Auth/Back.svg" alt="" onClick={() => {nav(-1)}}/>

                                <p className="font-unbounded text-left md:uppercase font-medium text-[20px]">пожалуйста, проверьте свою электронную почту</p>
                                <p className="uppercase text-[10px] font-medium font-montserrat w-full text-[#607E96]">мы отправили код на Вашу почту</p>

                                <div className="w-full flex justify-between gap-4">
                                    {code.map((digit, index) => (
                                        <input
                                            key={index}
                                            ref={(el) => (inputRefs.current[index] = el)}
                                            type="text"
                                            inputMode="numeric"
                                            maxLength={1}
                                            value={digit}
                                            onChange={(e) => handleCodeChange(e, index)}
                                            onKeyDown={(e) => handleKeyDown(e, index)}
                                            className="w-full aspect-square text-center text-2xl font-bold rounded-2xl border border-gray-300 focus:border-black outline-none transition-all"
                                        />
                                    ))}
                                </div>
                            </div>

                            <div className="w-full flex flex-col gap-10">

                                <p
                                    className={`text-center mb-5 font-montserrat ${
                                        timer === 0 ? 'cursor-pointer text-blue-500' : 'text-gray-400 cursor-not-allowed'
                                    }`}
                                    onClick={async () => {
                                        if (timer === 0) {
                                            await ResentCode(userInfo);
                                            startTimer(40);
                                        }
                                    }}
                                >
                                    {timer === 0
                                        ? 'отправить код повторно'
                                        : `отправить код повторно через 00:${timer < 10 ? `0${timer}` : timer}`}
                                </p>

                                <button
                                    className="w-full bg-[#1B3C4D] py-5 rounded-2xl mb-32"
                                    onClick={sendCode}
                                >
                                    <p className="uppercase font-unbounded font-light text-white">отправить</p>
                                </button>
                                <div className="text-center uppercase font-montserrat text-[#8296A6] text-[12px]">ЕЩЕ НЕТ аккаунтА? <span className="cursor-pointer text-black" onClick={() => {nav("/register")}}> ЗАРЕГИСТРИРОВАТЬСЯ</span> </div>
                                <div className="w-full hidden justify-center sm:flex">
                                    <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt="" onClick={() => {nav("/")}}/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
            {step === 3 && (
                <div className="w-full min-h-screen flex justify-center items-center">
                    <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                        <div className="w-full h-full flex flex-col justify-between gap-10">
                            <div className="w-full flex flex-col gap-5 justify-center items-center mt-14">
                                <img src="/photos/Auth/Star.svg" alt="" className="w-10 mb-5"/>
                                <p className="uppercase font-medium font-unbounded text-[#1B3C4D]">Почта подтверждена</p>
                                <p className="text-[#607E96] text-[10px] uppercase">Аккаунт успешно верфицирован</p>
                            </div>
                            <div className="w-full flex flex-col gap-10">
                                <button className="w-full bg-[#1B3C4D] py-5 rounded-2xl mb-32" onClick={() => {nav(MAIN)}}>
                                    <p className="uppercase font-unbounded font-light text-white">Вернуться ко входу</p>
                                </button>
                                <div className="text-center uppercase font-montserrat text-[#8296A6] text-[12px]">ЕЩЕ НЕТ аккаунтА? <span className="cursor-pointer text-black" onClick={() => {nav("/register")}}> ЗАРЕГИСТРИРОВАТЬСЯ</span> </div>
                                <div className="w-full hidden justify-center sm:flex">
                                    <img src="/photos/Auth/Register/cross-svgrepo-com.svg" className="w-8 cursor-pointer" alt="" onClick={() => {nav("/")}}/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Verify;