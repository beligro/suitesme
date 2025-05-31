import React from 'react';
import styles from './Results.module.css';

const Results = () => {
  return (
    <section className={styles.results} id="results">
      <div className={styles.container}>
        <h2 className={styles.heading}>Результаты</h2>
        
        <div className={styles.resultsGrid}>
          <div className={styles.resultCard}>
            <div className={styles.resultImage}></div>
            <div className={styles.resultInfo}>
              <h3 className={styles.resultTitle}>Анна, 28 лет</h3>
              <p className={styles.resultDescription}>
                "Благодаря анализу я наконец поняла, какие цвета и стили мне действительно подходят. Теперь я трачу меньше времени на выбор одежды и всегда выгляжу гармонично!"
              </p>
              <div className={styles.resultType}>Типаж: Драматик</div>
            </div>
          </div>
          
          <div className={styles.resultCard}>
            <div className={styles.resultImage}></div>
            <div className={styles.resultInfo}>
              <h3 className={styles.resultTitle}>Мария, 34 года</h3>
              <p className={styles.resultDescription}>
                "Всегда думала, что мне идут холодные оттенки, но анализ показал, что теплые тона гораздо лучше подчеркивают мою внешность. Это полностью изменило мой подход к макияжу!"
              </p>
              <div className={styles.resultType}>Типаж: Натурал</div>
            </div>
          </div>
          
          <div className={styles.resultCard}>
            <div className={styles.resultImage}></div>
            <div className={styles.resultInfo}>
              <h3 className={styles.resultTitle}>Екатерина, 26 лет</h3>
              <p className={styles.resultDescription}>
                "Мини-гайд, который я получила после анализа, стал моей настольной книгой. Теперь я точно знаю, какие фасоны и аксессуары выбирать."
              </p>
              <div className={styles.resultType}>Типаж: Романтик</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Results;
