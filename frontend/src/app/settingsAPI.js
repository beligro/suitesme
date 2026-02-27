import { $host } from "./indexAPI.js";

export const getPublicSettings = async () => {
    try {
        const { data } = await $host.get("/settings/public");
        return data;
    } catch (error) {
        console.log(error);
        return { price: "5990", old_price: null };
    }
};
