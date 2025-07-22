import React from "react";
// eslint-disable-next-line no-unused-vars
import { motion } from "framer-motion";
import { staggerContainer } from "../utils/motion";

const SectionWrapper = (Component, idName) =>
    function HOC() {
        return (
            <section id={idName} className="relative scroll-mt-20">
                <motion.div
                    variants={staggerContainer()}
                    initial="hidden"
                    whileInView="show"
                    viewport={{ once: true, amount: 0.25 }}
                >
                    <Component />
                </motion.div>
            </section>
        );
    };

export default SectionWrapper;