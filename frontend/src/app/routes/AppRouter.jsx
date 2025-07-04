import React, {Suspense, useEffect, useState} from 'react';
import {Routes, Route, Navigate, useLocation} from 'react-router-dom';
import {FORGOTT_PASSWORD, LOGIN, MAIN, PAYMENT, REGISTER, VERIFY} from './constans.js';
import { nonAuthorise, authorise, authRoutes } from './routes.js';
import {useDispatch, useSelector} from "react-redux";
import {selectIsAuthenticated} from "../../features/Auth/model/selector.js";
import {logout, resetUser, setIsAuthenticated, setUser} from "../../features/Auth/model/slice.js";
import {getUsersStyle} from "../../pages/Lk/api/lkAPI.js";
import Loading from "../../pages/Helpers/Loading.jsx";

const AppRouter = () => {
    const location = useLocation();

    const dispatch = useDispatch();
    const isAuth = useSelector(selectIsAuthenticated);

    const [loading, setLoading] = useState(true);


    const specialRoutesSet = new Set([
        MAIN,
        PAYMENT,
        LOGIN,
        REGISTER,
        FORGOTT_PASSWORD,
        VERIFY
    ]);

    useEffect(() => {
        const tryRestoreSession = async () => {
            const accessToken = localStorage.getItem("access_token");
            if (!accessToken) {
                setLoading(false);
                return;
            }

            try {
                const data = await getUsersStyle();
                dispatch(setIsAuthenticated(true));
                dispatch(setUser(data));
            } catch {
                dispatch(logout());
                dispatch(resetUser());
            } finally {
                setLoading(false);
            }
        };

        tryRestoreSession();
    }, []);

    if (loading) return <Loading />;

    return (
        <Suspense fallback={<Loading />}>
            <Routes>
                {isAuth && authorise.map(({ path, Component }) => (
                    <Route
                        key={path}
                        path={path}
                        element={
                        <Component />
                        }
                    />
                ))}
                {nonAuthorise.map(({ path, Component }) => (
                    <Route key={path} path={path} element={<Component />} />
                ))}
                { authRoutes.map(({ path, Component }) => (
                    <Route key={path} path={path} element={<Component />} />
                ))}

                <Route path="*" element={<Navigate to={MAIN} replace />} />
            </Routes>
        </Suspense>


    );
};

export default AppRouter;