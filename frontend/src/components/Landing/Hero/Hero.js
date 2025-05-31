import React from 'react';
import styles from './Hero.module.css';

const Hero = () => {
  return (
    <section className={styles.hero} id="hero">
      <div className={styles.container}>
        <div className={styles.content}>
          <h1 className={styles.heading}>
            Узнай, что тебе действительно идёт
          </h1>
          <p className={styles.subheading}>
            Наш искусственный интеллект анализирует черты лица и определяет типаж по системе MNE IDET
          </p>
          <button className={styles.ctaButton}>
            Узнать свой типаж
          </button>
        </div>
        <div className={styles.imageContainer}>
          <div className={styles.phoneImage}></div>
          <div className={styles.backgroundCircle}></div>
        </div>
      </div>
    </section>
  );
};

export default Hero;
