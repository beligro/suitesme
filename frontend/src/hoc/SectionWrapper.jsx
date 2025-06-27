import React from "react";
import {motion} from 'framer-motion'
import { staggerContainer } from "../utils/motion";

const SectionWrapper = (Component , idName)=>
    function HOC(){
        return(
            <motion.section
                variants={staggerContainer()}
                initial="hidden"
                whileInView='show'
                viewport={{once:true , amount:0.25}}
                className={``}

            >

            <span className="hah-span h-[0.05px]" id={idName}>
                &nbsp;
            </span>
                <Component/>
            </motion.section>
        )
    }


export default SectionWrapper