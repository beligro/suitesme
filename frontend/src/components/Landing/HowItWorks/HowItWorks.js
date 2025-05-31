import React from 'react';
import styles from './HowItWorks.module.css';

const HowItWorks = () => {
  return (
    <section className={styles.howItWorks} id="about">
      <div className={styles.container}>
        <h2 className={styles.heading}>Как это работает?</h2>
        
        <div className={styles.content}>
          <div className={styles.textContent}>
            <p className={styles.description}>
              Загрузи своё фото, и наш AI проанализирует твои черты лица и определит типаж
            </p>
            <div className={styles.bonusInfo}>
              <p className={styles.bonusText}>
                В подарок ты получишь мини-гайд о своем типаже
              </p>
              <div className={styles.arrowIcons}>
                <div className={styles.leftArrow}></div>
                <div className={styles.rightArrow}></div>
              </div>
            </div>
          </div>
          
          <div className={styles.imageSection}>
            <div className={styles.phoneContainer}>
              <div className={styles.phoneImage}></div>
            </div>
            <div className={styles.pricingCircle}>
              <p className={styles.pricingLabel}>стоимость</p>
              <p className={styles.price}>3990 ₽</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default HowItWorks;
