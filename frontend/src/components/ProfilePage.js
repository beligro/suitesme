import React, { useState, useEffect } from 'react';
import axiosInstance from './axiosConfig';
import Cookies from 'js-cookie';
import { useNavigate, useLocation } from 'react-router-dom';
import Modal from './Modal';

const ProfilePage = () => {
  const [profile, setProfile] = useState({ email: '', first_name: '', last_name: '', birth_date: '' });
  const [isEditing, setIsEditing] = useState(false);
  const [photoFile, setPhotoFile] = useState(null);
  const navigate = useNavigate();
  const location = useLocation();
  
  // Состояния для модального окна
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState(''); // 'payment', 'upload', 'result', 'paymentFailed'
  const [styleId, setStyleId] = useState(null);
  const [paymentLink, setPaymentLink] = useState('');
  const [paymentError, setPaymentError] = useState('');

  // Получаем данные профиля при первоначальной загрузке
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const response = await axiosInstance.get('/api/v1/profile/info');
        setProfile(response.data);
      } catch (error) {
        console.error('Ошибка загрузки профиля:', error);
      }
    };

    fetchProfile();
  }, []);

  // Проверяем параметр состояния после перенаправления с платежной страницы
  useEffect(() => {
    if (location.state && location.state.fromPayment) {
      if (location.state.paymentStatus === 'ok') {
        // Если оплата успешна, проверяем информацию о стиле
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
  }, [location, navigate]);

  const handleUpdateProfile = async () => {
    try {
      await axiosInstance.post('/api/v1/profile/edit', {
        first_name: profile.first_name,
        last_name: profile.last_name,
        birth_date: profile.birth_date
      });

      setIsEditing(false);
    } catch (error) {
      console.error('Ошибка обновления профиля:', error);
    }
  };

  const handlePhotoUpload = async (e) => {
    e.preventDefault();

    if (!photoFile) {
      console.error('Выберите файл для загрузки');
      return;
    }

    const formData = new FormData();
    formData.append('photo', photoFile);

    try {
      const response = await axiosInstance.post('/api/v1/style/build', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      setStyleId(response.data.style_id);
      setModalType('result');
    } catch (error) {
      console.error('Ошибка при загрузке фото:', error);
    }
  };

  // Вынесем получение ссылки для оплаты в отдельную функцию для переиспользования
  const fetchPaymentLink = async () => {
    try {
      const paymentResponse = await axiosInstance.get('/api/v1/payment/link');
      return paymentResponse.data.payment_link;
    } catch (error) {
      console.error('Ошибка получения ссылки на оплату:', error);
      throw error;
    }
  };

  const handleCheckStyle = async () => {
    try {
      const response = await axiosInstance.get('/api/v1/style/info');
      setStyleId(response.data.style_id);
      setModalType('result');
      setShowModal(true);
    } catch (error) {
      if (error.response && error.response.status === 403) {
        // Если не оплачено, получаем ссылку для оплаты
        try {
          const link = await fetchPaymentLink();
          setPaymentLink(link);
          setModalType('payment');
          setShowModal(true);
        } catch (paymentError) {
          console.error('Ошибка получения ссылки на оплату:', paymentError);
        }
      } else if (error.response && error.response.status === 404) {
        // Если необходимо загрузить фото
        setModalType('upload');
        setShowModal(true);
        setPhotoFile(null);
      } else {
        console.error('Ошибка при проверке стиля:', error);
      }
    }
  };

  const handleLogout = async () => {
    try {
      await axiosInstance.post('/api/v1/auth/logout', {refresh_token: Cookies.get('refresh_token')});
      Cookies.remove('access_token');
      Cookies.remove('refresh_token');
      localStorage.setItem('isAuthorized', 'false');
      navigate('/login');
    } catch (error) {
      console.error('Ошибка при выходе:', error);
    }
  };

  const closeModal = () => {
    setShowModal(false);
  };

  // Рендерим содержимое модального окна в зависимости от типа
  const renderModalContent = () => {
    switch (modalType) {
      case 'payment':
        return (
          <div>
            <h3>Не оплачено</h3>
            <p>Для определения вашего типажа необходимо произвести оплату</p>
            <a href={paymentLink} target="_blank" rel="noopener noreferrer">
              <button>Оплатить</button>
            </a>
            <button onClick={closeModal}>Закрыть</button>
          </div>
        );
      case 'paymentFailed':
        return (
          <div>
            <h3>Ошибка оплаты</h3>
            <p>{paymentError}</p>
            <a href={paymentLink} target="_blank" rel="noopener noreferrer">
              <button>Попробовать снова</button>
            </a>
            <button onClick={closeModal}>Закрыть</button>
          </div>
        );
      case 'upload':
        return (
          <div>
            <h3>Загрузите ваше фото</h3>
            <form onSubmit={handlePhotoUpload}>
              <input 
                type="file" 
                accept="image/*" 
                onChange={(e) => setPhotoFile(e.target.files[0])} 
              />
              <button type="submit">Отправить</button>
            </form>
            <button onClick={closeModal}>Отмена</button>
          </div>
        );
      case 'result':
        return (
          <div>
            <h3>Ваш типаж</h3>
            <p>ID вашего стиля: {styleId}</p>
            <button onClick={closeModal}>Закрыть</button>
          </div>
        );
      default:
        return null;
    }
  };

  return (
    <div>
      <h2>Профиль</h2>
      <div>
        <label>Почта: </label>
        <span>{profile.email}</span>
      </div>
      <div>
        <label>Имя: </label>
        {isEditing ? (
          <input
            type="text"
            value={profile.first_name}
            onChange={(e) => setProfile({ ...profile, first_name: e.target.value })}
          />
        ) : (
          <span>{profile.first_name}</span>
        )}
      </div>
      <div>
        <label>Фамилия: </label>
        {isEditing ? (
          <input
            type="text"
            value={profile.last_name}
            onChange={(e) => setProfile({ ...profile, last_name: e.target.value })}
          />
        ) : (
          <span>{profile.last_name}</span>
        )}
      </div>
      <div>
        <label>Дата рождения: </label>
        {isEditing ? (
          <input
            type="date"
            value={profile.birth_date}
            onChange={(e) => setProfile({ ...profile, birth_date: e.target.value })}
          />
        ) : (
          <span>{profile.birth_date}</span>
        )}
      </div>
      {isEditing ? (
        <button onClick={handleUpdateProfile}>Сохранить изменения</button>
      ) : (
        <button onClick={() => setIsEditing(true)}>Редактировать</button>
      )}
      
      <div>
        <h3>Стиль</h3>
        <button onClick={handleCheckStyle}>Узнать свой типаж</button>
      </div>

      <button onClick={handleLogout}>Выйти</button>

      {/* Модальное окно */}
      <Modal isOpen={showModal} onClose={() => setShowModal(false)}>
        {renderModalContent()}
      </Modal>
    </div>
  );
};

export default ProfilePage;
