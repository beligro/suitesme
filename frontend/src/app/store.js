import { configureStore } from "@reduxjs/toolkit";
import authReducer, { initialState as authInit }  from "../features/Auth/model/slice.js";

const token = localStorage.getItem('access_token');

const preloadedState = {
  auth: {
    ...authInit,
    isAuthenticated: !!token,
    isInitialized: true,
  },
};

export const store = configureStore({
    reducer: {
        auth: authReducer,
    },
    preloadedState
});