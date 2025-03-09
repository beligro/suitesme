import React, { useState, useEffect } from 'react';
import axiosInstance from './axiosConfig';
import Cookies from 'js-cookie';
import { useNavigate } from 'react-router-dom';

const ProfilePage = () => {
  const [profile, setProfile] = useState({ email: '', first_name: '', last_name: '', birth_date: '' });
  const [isEditing, setIsEditing] = useState(false);
  const [photoFile, setPhotoFile] = useState(null);
  const [uploadResponse, setUploadResponse] = useState(null);
  const navigate = useNavigate();

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
      const response = await axiosInstance.post('/api/v1/style/info', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      setUploadResponse(response.data); // Сохраняем ответ
    } catch (error) {
      console.error('Ошибка при загрузке фото:', error);
    }
  };

  const handleLogout = async () => {
    try {
      await axiosInstance.post('/api/v1/auth/logout', {refresh_token: Cookies.get('refresh_token')});
      // Удаляем токены из cookies
      Cookies.remove('access_token');
      Cookies.remove('refresh_token');
      localStorage.setItem('isAuthorized', 'false');
      // Перенаправление на страницу входа
      navigate('/login');
    } catch (error) {
      console.error('Ошибка при выходе:', error);
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
        <h3>Загрузить фото</h3>
        {uploadResponse ? (
          <div>
            <h4>Ответ сервера:</h4>


<pre>{JSON.stringify(uploadResponse, null, 2)}</pre>
          </div>
        ) : (
          <form onSubmit={handlePhotoUpload}>
            <input type="file" accept="image/*" onChange={(e) => setPhotoFile(e.target.files[0])} />
            <button type="submit">Отправить</button>
          </form>
        )}
      </div>

      <button onClick={handleLogout}>Выйти</button>
    </div>
  );
};

export default ProfilePage;
