import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import api from '../utils/api.js';
import { useAuth } from '../contexts/AuthContext.jsx';
import Modal from './Modal.jsx';
import './ProfilePage.css';

const ProfilePage = () => {
  // Состояние профиля и UI
  const [profile, setProfile] = useState({ email: '', first_name: '', last_name: '', birth_date: '' });
  const [isEditing, setIsEditing] = useState(false);
  const [photoFile, setPhotoFile] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  
  // Состояния для модального окна
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState(''); // 'payment', 'upload', 'result', 'paymentFailed', 'paymentProcessing'
  const [styleId, setStyleId] = useState(null);
  const [paymentLink, setPaymentLink] = useState('');
  const [paymentError, setPaymentError] = useState('');
  const [pollingInterval, setPollingInterval] = useState(null);
  
  // Хуки для навигации и аутентификации
  const navigate = useNavigate();
  const location = useLocation();
  const { logout } = useAuth();

  // Получение данных профиля при первоначальной загрузке
  const fetchProfile = useCallback(async () => {
    setIsLoading(true);
    try {
      const response = await api.get('/api/v1/profile/info');
      setProfile(response.data);
      setError('');
    } catch (error) {
      console.error('Ошибка загрузки профиля:', error);
      setError('Не удалось загрузить данные профиля. Пожалуйста, попробуйте позже.');
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchProfile();
  }, [fetchProfile]);

  // Обновление профиля
  const handleUpdateProfile = async () => {
    setIsLoading(true);
    setError('');
    
    try {
      await api.post('/api/v1/profile/edit', {
        first_name: profile.first_name,
        last_name: profile.last_name,
        birth_date: profile.birth_date
      });

      setIsEditing(false);
    } catch (error) {
      console.error('Ошибка обновления профиля:', error);
      setError('Не удалось обновить профиль. Пожалуйста, попробуйте позже.');
    } finally {
      setIsLoading(false);
    }
  };

  // Загрузка фото
  const handlePhotoUpload = async (e) => {
    e.preventDefault();

    if (!photoFile) {
      setError('Пожалуйста, выберите файл для загрузки');
      return;
    }

    setIsLoading(true);
    setError('');
    
    const formData = new FormData();
    formData.append('photo', photoFile);

    try {
      const response = await api.post('/api/v1/style/build', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      setStyleId(response.data.style_id);
      setModalType('result');
      setShowModal(true);
    } catch (error) {
      console.error('Ошибка при загрузке фото:', error);
      setError('Не удалось загрузить фото. Пожалуйста, попробуйте позже.');
    } finally {
      setIsLoading(false);
    }
  };

  // Получение ссылки для оплаты
  const fetchPaymentLink = useCallback(async () => {
    try {
      const paymentResponse = await api.get('/api/v1/payment/link');
      return paymentResponse.data.link;
    } catch (error) {
      console.error('Ошибка получения ссылки на оплату:', error);
      throw error;
    }
  }, []);

  // Проверка статуса оплаты
  const checkPaymentStatus = useCallback(async () => {
    try {
      const response = await api.get('/api/v1/payment/info');
      return response.data.payment_status;
    } catch (error) {
      console.error('Ошибка проверки статуса оплаты:', error);
      throw error;
    }
  }, []);

  // Запуск поллинга статуса оплаты
  const startPaymentStatusPolling = useCallback(() => {
    // Очищаем предыдущий интервал, если он существует
    if (pollingInterval) {
      clearInterval(pollingInterval);
    }
    
    // Устанавливаем новый интервал
    const interval = setInterval(async () => {
      try {
        const status = await checkPaymentStatus();
        
        // Если статус оплаты "paid", останавливаем поллинг и проверяем стиль
        if (status === 'paid') {
          clearInterval(interval);
          setPollingInterval(null);
          
          // Проверяем информацию о стиле
          try {
            const styleResponse = await api.get('/api/v1/style/info');
            setStyleId(styleResponse.data.style_id);
            setModalType('result');
            setShowModal(true);
          } catch (styleError) {
            if (styleError.response && styleError.response.status === 404) {
              // Если необходимо загрузить фото
              setModalType('upload');
              setShowModal(true);
              setPhotoFile(null);
            } else {
              console.error('Ошибка при проверке стиля:', styleError);
              setError('Не удалось проверить стиль. Пожалуйста, попробуйте позже.');
            }
          }
        } 
        // Если статус "failed" или "not_found", останавливаем поллинг и показываем ошибку
        else if (status === 'failed' || status === 'not_found') {
          clearInterval(interval);
          setPollingInterval(null);
          
          try {
            const link = await fetchPaymentLink();
            setPaymentLink(link);
            setPaymentError('Оплата не была выполнена. Пожалуйста, попробуйте снова.');
            setModalType('paymentFailed');
            setShowModal(true);
          } catch (linkError) {
            console.error('Ошибка получения ссылки на оплату:', linkError);
            setError('Не удалось получить ссылку на оплату. Пожалуйста, попробуйте позже.');
          }
        }
        // Если статус "in_progress", показываем сообщение о обработке
        else if (status === 'in_progress') {
          setModalType('paymentProcessing');
          setShowModal(true);
        }
        // Для статусов "created_link" и "in_progress" продолжаем поллинг
      } catch (error) {
        console.error('Ошибка при поллинге статуса оплаты:', error);
      }
    }, 5000); // Поллинг каждые 5 секунд
    
    setPollingInterval(interval);
    
    // Очистка интервала при размонтировании компонента
    return () => {
      clearInterval(interval);
    };
  }, [checkPaymentStatus]);

  // Очистка интервала поллинга при размонтировании компонента
  useEffect(() => {
    return () => {
      if (pollingInterval) {
        clearInterval(pollingInterval);
      }
    };
  }, [pollingInterval]);

  // Проверка стиля
  const handleCheckStyle = useCallback(async () => {
    setIsLoading(true);
    setError('');
    
    try {
      // Сначала проверяем статус оплаты
      const paymentStatus = await checkPaymentStatus();
      console.log('Payment status is: ', paymentStatus);
      
      // Обрабатываем различные статусы оплаты
      if (paymentStatus === 'paid') {
        // Если оплачено, проверяем информацию о стиле
        try {
          const response = await api.get('/api/v1/style/info');
          setStyleId(response.data.style_id);
          setModalType('result');
          setShowModal(true);
        } catch (styleError) {
          if (styleError.response && styleError.response.status === 404) {
            // Если необходимо загрузить фото
            setModalType('upload');
            setShowModal(true);
            setPhotoFile(null);
          } else {
            console.error('Ошибка при проверке стиля:', styleError);
            setError('Не удалось проверить стиль. Пожалуйста, попробуйте позже.');
          }
        }
      } else if (paymentStatus === 'failed' || paymentStatus === 'not_found') {
        // Если не оплачено, получаем ссылку для оплаты
        try {
          console.log('I am here');
          const link = await fetchPaymentLink();
          console.log('Payment link is: ', link);
          setPaymentLink(link);
          setModalType('payment');
          console.log('Payment modal is: ', modalType);
          setShowModal(true);
        } catch (paymentError) {
          console.error('Ошибка получения ссылки на оплату:', paymentError);
          setError('Не удалось получить ссылку на оплату. Пожалуйста, попробуйте позже.');
        }
      } else if (paymentStatus === 'in_progress') {
        // Если оплата в процессе, показываем соответствующее сообщение
        setModalType('paymentProcessing');
        setShowModal(true);
        
        // Запускаем поллинг для статусов "in_progress"
        startPaymentStatusPolling();
      } else if (paymentStatus === 'created_link') {
        // Если ссылка создана, но оплата не начата, получаем ссылку для оплаты
        try {
          const link = await fetchPaymentLink();
          setPaymentLink(link);
          setModalType('payment');
          setShowModal(true);
          
          // Запускаем поллинг для статуса "created_link"
          startPaymentStatusPolling();
        } catch (paymentError) {
          console.error('Ошибка получения ссылки на оплату:', paymentError);
          setError('Не удалось получить ссылку на оплату. Пожалуйста, попробуйте позже.');
        }
      }
    } catch (error) {
      // Если произошла ошибка при проверке статуса оплаты, пробуем проверить стиль напрямую
      try {
        const response = await api.get('/api/v1/style/info');
        setStyleId(response.data.style_id);
        setModalType('result');
        setShowModal(true);
      } catch (styleError) {
        if (styleError.response && styleError.response.status === 403) {
          // Если не оплачено, получаем ссылку для оплаты
          try {
            const link = await fetchPaymentLink();
            setPaymentLink(link);
            setModalType('payment');
            setShowModal(true);
          } catch (paymentError) {
            console.error('Ошибка получения ссылки на оплату:', paymentError);
            setError('Не удалось получить ссылку на оплату. Пожалуйста, попробуйте позже.');
          }
        } else if (styleError.response && styleError.response.status === 404) {
          // Если необходимо загрузить фото
          setModalType('upload');
          setShowModal(true);
          setPhotoFile(null);
        } else {
          console.error('Ошибка при проверке стиля:', styleError);
          setError('Не удалось проверить стиль. Пожалуйста, попробуйте позже.');
        }
      }
    } finally {
      setIsLoading(false);
    }
  }, [checkPaymentStatus, fetchPaymentLink, startPaymentStatusPolling]);

  // Выход из аккаунта
  const handleLogout = async () => {
    try {
      const refreshToken = localStorage.getItem('refresh_token');
      if (refreshToken) {
        await api.post('/api/v1/auth/logout', { refresh_token: refreshToken });
      }
      logout();
    } catch (error) {
      console.error('Ошибка при выходе:', error);
      // Даже если запрос не удался, все равно выходим локально
      logout();
    }
  };
  
  // Проверяем параметр состояния после перенаправления с платежной страницы
  // Размещаем этот useEffect после определения всех необходимых функций
  useEffect(() => {
    if (location.state && location.state.fromPayment) {
      if (location.state.paymentStatus === 'ok') {
        // Если оплата успешна, проверяем статус оплаты через API
        handleCheckStyle();
      } else if (location.state.paymentStatus === 'fail') {
        // Если оплата не удалась, показываем сообщение об ошибке и предлагаем повторить
        fetchPaymentLink()
          .then(link => {
            setPaymentLink(link);
            setPaymentError('Оплата не была выполнена. Пожалуйста, попробуйте снова.');
            setModalType('paymentFailed');
            setShowModal(true);
          })
          .catch(error => {
            console.error('Ошибка получения ссылки на оплату:', error);
          });
      }
      
      // Очищаем состояние, чтобы избежать повторного срабатывания при обновлении страницы
      navigate(location.pathname, { replace: true });
    }
  }, [location, navigate, handleCheckStyle, fetchPaymentLink]);

  // Закрытие модального окна
  const closeModal = () => {
    setShowModal(false);
    
    // Если модальное окно закрывается, и это окно обработки платежа,
    // то останавливаем поллинг
    if ((modalType === 'paymentProcessing' || modalType === 'payment' || modalType === 'paymentFailed') && pollingInterval) {
      clearInterval(pollingInterval);
      setPollingInterval(null);
    }
  };

  // Рендерим содержимое модального окна в зависимости от типа
  const renderModalContent = () => {
    switch (modalType) {
      case 'payment':
        return (
          <div className="modal-content-wrapper">
            <h3 className="modal-title">Не оплачено</h3>
            <p className="modal-text">Для определения вашего типажа необходимо произвести оплату</p>
            <div className="modal-actions">
              <button 
                className="btn btn-primary"
                onClick={() => {
                  // Открываем ссылку в новом окне
                  window.open(paymentLink, '_blank');
                  
                  // Запускаем поллинг статуса оплаты
                  startPaymentStatusPolling();
                }}
              >
                Оплатить
              </button>
              <button onClick={closeModal} className="btn btn-outline">Закрыть</button>
            </div>
          </div>
        );
      case 'paymentProcessing':
        return (
          <div className="modal-content-wrapper">
            <h3 className="modal-title">Обработка оплаты</h3>
            <p className="modal-text">Оплата находится в обработке. Пожалуйста, подождите.</p>
            <div className="loading-spinner"></div>
            <div className="modal-actions">
              <button onClick={closeModal} className="btn btn-outline">Закрыть</button>
            </div>
          </div>
        );
      case 'paymentFailed':
        return (
          <div className="modal-content-wrapper">
            <h3 className="modal-title">Ошибка оплаты</h3>
            <p className="modal-text error-text">{paymentError}</p>
            <div className="modal-actions">
              <button 
                className="btn btn-primary"
                onClick={() => {
                  // Открываем ссылку в новом окне
                  window.open(paymentLink, '_blank');
                  
                  // Запускаем поллинг статуса оплаты
                  startPaymentStatusPolling();
                }}
              >
                Попробовать снова
              </button>
              <button onClick={closeModal} className="btn btn-outline">Закрыть</button>
            </div>
          </div>
        );
      case 'upload':
        return (
          <div className="modal-content-wrapper">
            <h3 className="modal-title">Загрузите ваше фото</h3>
            <p className="modal-text">Загрузите фотографию для определения вашего типажа</p>
            <form onSubmit={handlePhotoUpload} className="upload-form">
              <div className="file-input-wrapper">
                <input 
                  type="file" 
                  accept="image/*" 
                  onChange={(e) => setPhotoFile(e.target.files[0])} 
                  className="file-input"
                  id="photo-upload"
                />
                <label htmlFor="photo-upload" className="file-label">
                  {photoFile ? photoFile.name : 'Выберите файл'}
                </label>
              </div>
              <div className="modal-actions">
                <button type="submit" className="btn btn-primary" disabled={!photoFile || isLoading}>
                  {isLoading ? 'Загрузка...' : 'Отправить'}
                </button>
                <button type="button" onClick={closeModal} className="btn btn-outline">Отмена</button>
              </div>
            </form>
          </div>
        );
      case 'result':
        return (
          <div className="modal-content-wrapper">
            <h3 className="modal-title">Ваш типаж</h3>
            <div className="style-result">
              <p className="modal-text">ID вашего стиля: <span className="style-id">{styleId}</span></p>
              <p className="style-description">
                Здесь будет отображаться информация о вашем типаже и рекомендации по стилю.
              </p>
            </div>
            <div className="modal-actions">
              <button onClick={closeModal} className="btn btn-primary">Закрыть</button>
            </div>
          </div>
        );
      default:
        return null;
    }
  };

  // Показываем индикатор загрузки, если данные профиля еще не загружены
  if (isLoading && !profile.email) {
    return (
      <div className="profile-loading">
        <div className="loading-spinner"></div>
        <p>Загрузка профиля...</p>
      </div>
    );
  }

  return (
    <div className="profile-page">
      <div className="profile-card">
        <div className="profile-header">
          <h2 className="profile-title">Личный кабинет</h2>
        </div>

        {error && <div className="alert alert-error">{error}</div>}

        <div className="profile-content">
          <div className="profile-section">
            <h3 className="section-title">Личная информация</h3>
            
            <div className="profile-info">
              <div className="info-group">
                <label className="info-label">Почта:</label>
                <div className="info-value">{profile.email}</div>
              </div>
              
              <div className="info-group">
                <label className="info-label">Имя:</label>
                {isEditing ? (
                  <input
                    type="text"
                    value={profile.first_name || ''}
                    onChange={(e) => setProfile({ ...profile, first_name: e.target.value })}
                    className="info-input"
                    disabled={isLoading}
                  />
                ) : (
                  <div className="info-value">{profile.first_name || '—'}</div>
                )}
              </div>
              
              <div className="info-group">
                <label className="info-label">Фамилия:</label>
                {isEditing ? (
                  <input
                    type="text"
                    value={profile.last_name || ''}
                    onChange={(e) => setProfile({ ...profile, last_name: e.target.value })}
                    className="info-input"
                    disabled={isLoading}
                  />
                ) : (
                  <div className="info-value">{profile.last_name || '—'}</div>
                )}
              </div>
              
              <div className="info-group">
                <label className="info-label">Дата рождения:</label>
                {isEditing ? (
                  <input
                    type="date"
                    value={profile.birth_date || ''}
                    onChange={(e) => setProfile({ ...profile, birth_date: e.target.value })}
                    className="info-input"
                    disabled={isLoading}
                  />
                ) : (
                  <div className="info-value">{profile.birth_date || '—'}</div>
                )}
              </div>
            </div>
            
            <div className="profile-actions">
              {isEditing ? (
                <button 
                  onClick={handleUpdateProfile} 
                  className="btn btn-primary"
                  disabled={isLoading}
                >
                  {isLoading ? 'Сохранение...' : 'Сохранить изменения'}
                </button>
              ) : (
                <button 
                  onClick={() => setIsEditing(true)} 
                  className="btn btn-outline"
                >
                  Редактировать
                </button>
              )}
            </div>
          </div>
          
          <div className="profile-section">
            <h3 className="section-title">Мой стиль</h3>
            <p className="section-description">
              Узнайте свой типаж и получите персональные рекомендации по стилю
            </p>
            <div className="profile-actions">
              <button 
                onClick={handleCheckStyle} 
                className="btn btn-primary"
                disabled={isLoading}
              >
                {isLoading ? 'Загрузка...' : 'Узнать свой типаж'}
              </button>
            </div>
          </div>
          
          <div className="profile-section">
            <div className="profile-actions">
              <button onClick={handleLogout} className="btn btn-outline">Выйти из аккаунта</button>
            </div>
          </div>
        </div>
      </div>

      {/* Модальное окно */}
      <Modal isOpen={showModal} onClose={closeModal}>
        {renderModalContent()}
      </Modal>
    </div>
  );
};

export default ProfilePage;
