import {lazy} from "react";
import {FORGOTT_PASSWORD, LK, LOGIN, MAIN, PAYMENT, REGISTER, VERIFY} from "./constans.js";
import Verify from "../../pages/Auth/Verify/Verify.jsx";

const HomePage = lazy(() => import("../../pages/HomePage/HomePage.jsx"));
const WhereMoney = lazy(() => import("../../pages/Lk/WhereMoney.jsx"));
const Lk = lazy(() => import("../../pages/Lk/LK.jsx"));
const Login = lazy(() => import("../../pages/Auth/Login/Login.jsx"));
const Register = lazy(() => import("../../pages/Auth/Register/Register.jsx"));
const ForgotPassword = lazy(() => import("../../pages/Auth/ForgotPassword/ForgotPassword.jsx"));



export const nonAuthorise = [
    {
        path: MAIN,
        Component: HomePage,
    },
    {
        path: PAYMENT,
        Component: WhereMoney,
    },
    {
        path: LOGIN,
        Component: Login,
    },
    {
        path: REGISTER,
        Component: Register,
    },
    {
        path: FORGOTT_PASSWORD,
        Component: ForgotPassword,
    },
    {
        path:VERIFY,
        Component: Verify,
    }
]

export const authorise = [
    {
        path: LK,
        Component: Lk,
    },
]
