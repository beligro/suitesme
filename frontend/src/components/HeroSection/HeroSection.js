import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import styles from './HeroSection.module.css';

const HeroSection = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();

  const handleCTAClick = () => {
    if (isAuthenticated) {
      navigate('/profile');
    } else {
      navigate('/register');
    }
  };

  return (
    <section className={styles.heroSection}>
      {/* Background Images and Effects */}
      <div className={styles.backgroundImages}>
        <div className={styles.mainBackground}></div>
        <div className={styles.leftGradient}></div>
        <div className={styles.rightGradient}></div>
        <div className={styles.blurredImage1}></div>
        <div className={styles.blurredImage2}></div>
        <div className={styles.blurredCircle1}></div>
        <div className={styles.blurredCircle2}></div>
      </div>

      {/* Content */}
      <div className={styles.content}>
        <h1 className={styles.title}>
          Узнай,<br />
          что тебе<br />
          действи-тельно<br />
          идёт
        </h1>
        
        <div className={styles.description}>
          <div className={styles.descriptionBorder1}></div>
          <div className={styles.descriptionBorder2}></div>
          <p className={styles.descriptionText}>
            Наш искусственный интеллект анализирует черты лица и определяет типаж по системе<br />
            <strong>MNE IDET</strong>
          </p>
        </div>
        
        <button 
          className={styles.ctaButton}
          onClick={handleCTAClick}
        >
          Узнать свой типаж
        </button>
      </div>
    </section>
  );
};

export default HeroSection;
