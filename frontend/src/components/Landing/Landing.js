import React from 'react';
import styles from './Landing.module.css';
import Header from './Header/Header';
import Hero from './Hero/Hero';
import HowItWorks from './HowItWorks/HowItWorks';
import Benefits from './Benefits/Benefits';
import Results from './Results/Results';
import FAQ from './FAQ/FAQ';
import Footer from './Footer/Footer';

const Landing = () => {
  return (
    <div className={styles.landing}>
      <Header />
      <main>
        <Hero />
        <HowItWorks />
        <Benefits />
        <Results />
        <FAQ />
      </main>
      <Footer />
    </div>
  );
};

export default Landing;
