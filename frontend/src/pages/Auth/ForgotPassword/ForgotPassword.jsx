import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { $host } from "../../../app/indexAPI.js";

const ForgotPassword = () => {
    const nav = useNavigate();

    /** ----- Шаги -----
     * 0 – ввод email
     * 1 – ввод кода
     * 2 – ввод нового пароля
     * 3 – успех
     */
    const [step, setStep] = useState(0);

    /* ───────────   step 0 ─────────── */
    const [values, setValues] = useState({ email: "" });
    const [errors, setErrors] = useState({});
    const [isSendingMail, setIsSendingMail] = useState(false);

    /* ───────────   step 1 ─────────── */
    const [code, setCode] = useState(["", "", "", "", "", ""]);
    const inputRefs = useRef([]);
    const [timer, setTimer] = useState(40);
    const timerRef = useRef(null);
    const [resetToken, setResetToken] = useState(""); // сохраним код сюда

    /* ───────────   step 2 ─────────── */
    const [pwd, setPwd] = useState({ password: "", password_confirm: "" });
    const [pwdErr, setPwdErr] = useState({});
    const [pwdLoading, setPwdLoading] = useState(false);

    /* ────────────────────────────────────────────────── */
    /* ----------------–– helpers ––--------------------  */
    const validateEmail = () => {
        const errs = {};
        if (!values.email) errs.email = "Email обязателен";
        else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(values.email))
            errs.email = "Некорректный email";
        return errs;
    };

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

    useEffect(() => {
        if (step === 1) startTimer(40);
        return () => clearInterval(timerRef.current);
    }, [step]);

    /* ────────────────────────────────────────────────── */
    /* ----------------–  step 0  –---------------------- */
    const sendMail = async () => {
        const vErr = validateEmail();
        setErrors(vErr);
        if (Object.keys(vErr).length) return;

        try {
            setIsSendingMail(true);
            await $host.post("/auth/forgot_password", { email: values.email });
            setStep(1);
        } catch (e) {
            alert(e.response?.data?.message ?? "Ошибка отправки письма");
        } finally {
            setIsSendingMail(false);
        }
    };

    /* ────────────────────────────────────────────────── */
    /* ----------------–  step 1  –---------------------- */
    const handleCodeChange = (val, idx) => {
        if (!/^\d?$/.test(val)) return;
        const next = [...code];
        next[idx] = val;
        setCode(next);
        if (val && idx < 5) inputRefs.current[idx + 1]?.focus();
    };
    const handleKey = (e, idx) => {
        if (e.key === "Backspace" && !code[idx] && idx > 0)
            inputRefs.current[idx - 1]?.focus();
    };

    const handleCodeSubmit = () => {
        const token = code.join("");
        if (token.length !== 4) return alert("Введите 4-значный код");
        setResetToken(token);
        setStep(2);
    };

    /* ────────────────────────────────────────────────── */
    /* ----------------–  step 2  –---------------------- */
    const validatePwd = () => {
        const pe = {};
        if (!pwd.password) pe.password = "Пароль обязателен";
        if (!pwd.password_confirm) pe.password_confirm = "Подтвердите пароль";
        if (pwd.password && pwd.password !== pwd.password_confirm)
            pe.password_confirm = "Пароли не совпадают";
        return pe;
    };

    const sendNewPassword = async () => {
        const pe = validatePwd();
        setPwdErr(pe);
        if (Object.keys(pe).length) return;

        try {
            setPwdLoading(true);
            await $host.post("/auth/password/reset", {
                password:pwd.password,
                password_confirm:pwd.password_confirm,
                reset_token:resetToken,
            });
            setStep(3);
        } catch (e) {
            alert(e.response?.data?.message ?? "Ошибка смены пароля");
        } finally {
            setPwdLoading(false);
        }
    };



    return (
        <div>
            {step === 0 && (
                <form
                    onSubmit={async (e) => {
                        e.preventDefault();
                        await sendMail();
                    }}
                    className="w-full min-h-screen flex justify-center items-center"
                >
                    <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                        <div className="w-full h-full flex flex-col justify-between gap-10">
                            <div className="w-full flex flex-col gap-10 relative">
                                <div className="md:hidden flex flex-row items-center justify-between w-full">
                                    <img src="/photos/Auth/Back.svg" alt="" className="cursor-pointer w-10" onClick={() => {nav(-1)}}/>
                                    <img src="/photos/Auth/Star.svg" alt="" className="w-10" />
                                </div>

                                <img className="md:block hidden absolute -left-20 cursor-pointer" src="/photos/Auth/Back.svg" alt="" onClick={() => {nav(-1)}}/>

                                <p className="font-unbounded text-left md:uppercase font-medium text-[20px]">забыли пароль?</p>
                                <p className="uppercase text-[10px] font-medium font-montserrat w-full text-[#607E96]">не волнуйтесь! такое случается. Пожалуйста, введите адрес электронной почты , связанный с вашей учетной записью.</p>
                                <div className="w-full flex flex-col gap-2">
                                    <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">email</p>
                                    <input
                                        name="email"
                                        value={values.email}
                                        onChange={(e) => setValues({ ...values, [e.target.name]: e.target.value })}
                                        className="border-b px-3 py-2 rounded-2xl"
                                    />
                                    {errors.email && (
                                        <p className="text-red-500 text-xs">{errors.email}</p>
                                    )}
                                </div>
                            </div>
                            <div className="w-full flex flex-col gap-10">
                                <button
                                    className="w-full bg-[#1B3C4D] py-5 rounded-2xl mb-32"
                                    disabled={isSendingMail}
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
                </form>
            )}
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
                                <p className="uppercase text-[10px] font-medium font-montserrat w-full text-[#607E96]">мы отправили код по адресу {values.email}</p>

                                <div className="w-full flex justify-between gap-4">
                                    {code.map((digit, index) => (
                                        <input
                                            key={index}
                                            ref={(el) => (inputRefs.current[index] = el)}
                                            type="text"
                                            inputMode="numeric"
                                            maxLength={1}
                                            value={digit}
                                            onChange={(e) => handleCodeChange(e.target.value, index)}
                                            onKeyDown={(e) => handleKey(e, index)}
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
                                            await sendMail();
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
                                    onClick={handleCodeSubmit}
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
            {step === 2 && (
                <div className="w-full min-h-screen flex justify-center items-center">
                    <div className="sm:w-[400px] w-full sm:p-0 p-5 h-[780px]">
                        <div className="w-full h-full flex flex-col justify-between gap-10">
                            <div className="w-full flex flex-col gap-10 relative">
                                <div className="md:hidden flex flex-row items-center justify-between w-full">
                                    <img src="/photos/Auth/Back.svg" alt="" className="cursor-pointer w-10" onClick={() => {nav(-1)}}/>
                                    <img src="/photos/Auth/Star.svg" alt="" className="w-10" />
                                </div>

                                <img className="md:block hidden absolute -left-20 cursor-pointer" src="/photos/Auth/Back.svg" alt="" onClick={() => {nav(-1)}}/>

                                <p className="font-unbounded text-left md:uppercase font-medium text-[20px]">введите новый пароль</p>
                                <p className="uppercase text-[10px] font-medium font-montserrat w-full text-[#607E96]">пожалуйста, придумайте сложный пароль</p>
                                <div className="w-full flex flex-col gap-2">
                                    <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">пароль</p>
                                    <input
                                        name="password"
                                        type="password"
                                        value={pwd.password}
                                        onChange={(e) => setPwd({ ...pwd, [e.target.name]: e.target.value })}
                                        className="border-b px-3 py-2 rounded-2xl"
                                    />
                                    {pwdErr.password && <p className="text-red-500 text-xs">{pwdErr.password}</p>}
                                </div>

                                <div className="w-full flex flex-col gap-2">
                                    <p className="uppercase font-montserrat text-[12px] font-medium text-[#1B3C4D]">подтвердить пароль</p>
                                    <input
                                        name="password_confirm"
                                        type="password"
                                        value={pwd.password_confirm}
                                        onChange={(e) => setPwd({ ...pwd, [e.target.name]: e.target.value })}
                                        className="border-b px-3 py-2 rounded-2xl"
                                    />
                                    {pwdErr.password_confirm && <p className="text-red-500 text-xs">{pwdErr.password_confirm}</p>}
                                </div>
                            </div>
                            <div className="w-full flex flex-col gap-10">
                                <button
                                    className="w-full bg-[#1B3C4D] py-5 rounded-2xl mb-32"
                                    onClick={sendNewPassword}
                                    disabled={pwdLoading}
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
                                <p className="uppercase font-medium font-unbounded text-[#1B3C4D]">пароль изменен</p>
                                <p className="text-[#607E96] text-[10px] uppercase">ваш пароль был успешно изменен</p>
                            </div>
                            <div className="w-full flex flex-col gap-10">
                                <button className="w-full bg-[#1B3C4D] py-5 rounded-2xl mb-32" onClick={() => {nav("/")}}>
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

export default ForgotPassword;