import React, {useEffect} from 'react'
import './App.css'
import './index.css'
import {useNavigationHandler} from "./components/NavigationHandlerContext.jsx";
import {useAuth} from "./contexts/AuthContext.jsx";
import {setNavigationCallback} from "./utils/api.js";
import HomePage from "./pages/HomePage/HomePage.jsx";
import AuthPage from "./components/AuthPage.jsx";
import RegisterPage from "./components/RegisterPage.jsx";
import VerifyEmailPage from "./components/VerifyEmailPage.jsx";
import ForgotPasswordPage from "./components/ForgotPasswordPage.jsx";
import PasswordResetPage from "./components/PasswordResetPage.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import ProfilePage from "./components/ProfilePage.jsx";
import PaymentRedirect from "./components/PaymentRedirect.jsx";
import {Route, Routes} from "react-router-dom";
import './styles/global.css'

function App() {
    const handleNavigation = useNavigationHandler();
    const { isAuthenticated } = useAuth();

    // Устанавливаем callback для навигации в API
    useEffect(() => {
        setNavigationCallback(handleNavigation);
    }, [handleNavigation]);

    return (
            <Routes>
                {/* Публичные маршруты */}
                <Route path="/" element={<HomePage />} />
                <Route path="/login" element={<AuthPage />} />
                <Route path="/register" element={<RegisterPage />} />
                <Route path="/verify_email" element={<VerifyEmailPage />} />
                <Route path="/forgotpassword" element={<ForgotPasswordPage />} />
                <Route path="/password_reset" element={<PasswordResetPage />} />

                {/* Защищенные маршруты */}
                <Route element={<ProtectedRoute />}>
                    <Route path="/profile" element={<ProfilePage />} />
                    <Route path="/profile/payment" element={<PaymentRedirect />} />
                </Route>
            </Routes>
    );
};

export default App
