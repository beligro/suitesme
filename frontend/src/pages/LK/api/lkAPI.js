import {$authHost} from "../../../app/indexAPI.js";

export const  getUsersStyle = async () => {
    try {
        const {data} =await  $authHost(`/profile/info`)
        return data
    }catch (error) {
        throw error;
    }
}