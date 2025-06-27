import { configureStore } from "@reduxjs/toolkit";
import authReducer from "../features/Auth/model/slice.js";


export const store = configureStore({
    reducer: {
        auth: authReducer,
    },
});