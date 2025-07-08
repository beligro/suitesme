import React, { useEffect} from 'react';
import {Routes, Route, Navigate} from 'react-router-dom';
import { MAIN} from './constans.js';
import { nonAuthorise, authorise } from './routes.js';
import {useDispatch, useSelector} from "react-redux";
import {selectIsAuthenticated , selectIsInitialized} from "../../features/Auth/model/selector.js";
import {logout, resetUser, setInitialized, setIsAuthenticated, setUser} from "../../features/Auth/model/slice.js";
import {getUsersStyle} from "../../pages/Lk/api/lkAPI.js";

const AppRouter = () => {
    const dispatch = useDispatch();
    const isAuth = useSelector(selectIsAuthenticated);
    const isInitialized = useSelector(selectIsInitialized);


    useEffect(() => {
        const tryRestoreSession = async () => {
            const accessToken = localStorage.getItem("access_token");
            if (!accessToken) {
                dispatch(setInitialized());
                return;
            }


            try {
                const data = await getUsersStyle();
                dispatch(setIsAuthenticated(true));
                dispatch(setUser(data));
            } catch {
                dispatch(logout());
                dispatch(resetUser());
            }finally {
                dispatch(setInitialized());
            }
        };

        tryRestoreSession();
    }, []);

    if (!isInitialized) {
        return <div className="fixed inset-0 z-[9999] bg-white/40 backdrop-blur-md transition-opacity duration-200 pointer-events-none opacity-100" />;
    }


    return (
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

                <Route path="*" element={<Navigate to={MAIN} replace />} />
            </Routes>
    );
};

export default AppRouter;
