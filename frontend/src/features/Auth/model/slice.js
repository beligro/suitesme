import { createSlice } from "@reduxjs/toolkit";


const initialState = {
    isAuthenticated: false,
    isInitialized: false,
    user:{
        email:null,
        first_name:null,
        last_name:null,
        birth_date:null
    }
};

const authSlice = createSlice({
    name: "auth",
    initialState,
    reducers: {
        setIsAuthenticated(state , action) {
            state.isAuthenticated = action.payload;
        },
        setUser(state , action) {
            state.user = action.payload;
        },
        resetUser(state ) {
            state.user=initialState.user;
        },
        login: (state, action) => {
            state.isAuthenticated = true;
            localStorage.setItem('access_token', action.payload.access_token);
            localStorage.setItem('refresh_token', action.payload.refresh_token);
        },
        logout: (state) => {
            state.isAuthenticated = false;

            localStorage.removeItem('access_token');
            localStorage.removeItem('refresh_token');
        },
        setInitialized(state) { state.isInitialized = true },
    },
});

export const { login, logout , setIsAuthenticated,setUser, resetUser, setInitialized } = authSlice.actions;
export default authSlice.reducer;