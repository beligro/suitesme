import React, { useState } from 'react';
import styles from './FAQ.module.css';

const FAQ = () => {
  // FAQ items data
  const faqItems = [
    {
      question: 'Как работает определение типажа?',
      answer: 'Наш искусственный интеллект анализирует загруженное вами фото, определяя более 100 параметров лица, включая пропорции, форму, черты и цветовые характеристики. На основе этих данных система определяет ваш типаж по методике MNE IDET.'
    },
    {
      question: 'Какие фотографии подходят для анализа?',
      answer: 'Для наиболее точного анализа рекомендуем использовать фотографии в хорошем качестве, при дневном освещении, без макияжа, с собранными волосами и нейтральным выражением лица. Фото должно быть анфас, с видимыми чертами лица.'
    },
    {
      question: 'Что входит в мини-гайд?',
      answer: 'Мини-гайд включает в себя подробное описание вашего типажа, рекомендации по цветовой гамме в одежде и макияже, советы по подбору фасонов одежды, аксессуаров и причесок, а также примеры удачных образов для вашего типажа.'
    },
    {
      question: 'Можно ли получить консультацию стилиста?',
      answer: 'Да, после получения результатов анализа вы можете заказать дополнительную консультацию с профессиональным стилистом. Стилист поможет разобрать ваш гардероб и составить персональные рекомендации с учетом вашего типажа.'
    },
    {
      question: 'Как долго ждать результаты?',
      answer: 'Результаты анализа и мини-гайд вы получите в течение 24 часов после загрузки фотографии и оплаты услуги. В периоды высокой загрузки время ожидания может увеличиться до 48 часов.'
    }
  ];

  // State to track which FAQ item is open
  const [openIndex, setOpenIndex] = useState(null);

  // Toggle FAQ item
  const toggleFAQ = (index) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <section className={styles.faq} id="faq">
      <div className={styles.container}>
        <h2 className={styles.heading}>Ответы на вопросы</h2>
        
        <div className={styles.faqList}>
          {faqItems.map((item, index) => (
            <div 
              key={index} 
              className={`${styles.faqItem} ${openIndex === index ? styles.open : ''}`}
            >
              <div 
                className={styles.faqQuestion}
                onClick={() => toggleFAQ(index)}
              >
                <h3>{item.question}</h3>
                <div className={styles.faqToggle}>
                  <span></span>
                  <span></span>
                </div>
              </div>
              <div className={styles.faqAnswer}>
                <p>{item.answer}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default FAQ;
