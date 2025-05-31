import React from 'react';
import styles from './Benefits.module.css';

const Benefits = () => {
  return (
    <section className={styles.benefits} id="benefits">
      <div className={styles.container}>
        <h2 className={styles.heading}>Преимущества</h2>
        
        <div className={styles.benefitsList}>
          <div className={styles.benefitCard}>
            <div className={styles.benefitIcon}></div>
            <h3 className={styles.benefitTitle}>Точный анализ</h3>
            <p className={styles.benefitDescription}>
              Наш AI анализирует более 100 параметров лица для определения вашего типажа
            </p>
          </div>
          
          <div className={styles.benefitCard}>
            <div className={styles.benefitIcon}></div>
            <h3 className={styles.benefitTitle}>Персональные рекомендации</h3>
            <p className={styles.benefitDescription}>
              Получите индивидуальные советы по стилю, цветам и макияжу
            </p>
          </div>
          
          <div className={styles.benefitCard}>
            <div className={styles.benefitIcon}></div>
            <h3 className={styles.benefitTitle}>Экономия времени</h3>
            <p className={styles.benefitDescription}>
              Больше не нужно тратить часы на подбор образа - AI сделает это за вас
            </p>
          </div>
          
          <div className={styles.benefitCard}>
            <div className={styles.benefitIcon}></div>
            <h3 className={styles.benefitTitle}>Доступ к мини-гайду</h3>
            <p className={styles.benefitDescription}>
              В подарок вы получите подробный гайд о вашем типаже
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Benefits;
