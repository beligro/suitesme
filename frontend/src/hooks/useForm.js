import { useState, useCallback } from 'react';
import { validateForm } from '../utils/validation.js';

/**
 * Хук для управления формами с валидацией
 * @param {Object} initialValues - Начальные значения полей формы
 * @param {Object} validationRules - Правила валидации полей
 * @param {Function} onSubmit - Функция, вызываемая при успешной отправке формы
 * @returns {Object} - Объект с методами и состоянием формы
 */
const useForm = (initialValues = {}, validationRules = {}, onSubmit = () => {}) => {
  // Состояние значений формы
  const [values, setValues] = useState(initialValues);
  
  // Состояние ошибок валидации
  const [errors, setErrors] = useState({});
  
  // Состояние отправки формы
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  // Состояние успешной отправки
  const [isSubmitted, setIsSubmitted] = useState(false);
  
  // Обработчик изменения значения поля
  const handleChange = useCallback((e) => {
    const { name, value, type, checked } = e.target;
    
    // Для чекбоксов используем checked, для остальных полей - value
    const fieldValue = type === 'checkbox' ? checked : value;
    
    setValues(prevValues => ({
      ...prevValues,
      [name]: fieldValue
    }));
    
    // Очищаем ошибку для измененного поля
    if (errors[name]) {
      setErrors(prevErrors => ({
        ...prevErrors,
        [name]: ''
      }));
    }
  }, [errors]);
  
  // Обработчик изменения значения поля (программно)
  const setValue = useCallback((name, value) => {
    setValues(prevValues => ({
      ...prevValues,
      [name]: value
    }));
    
    // Очищаем ошибку для измененного поля
    if (errors[name]) {
      setErrors(prevErrors => ({
        ...prevErrors,
        [name]: ''
      }));
    }
  }, [errors]);
  
  // Валидация формы
  const validate = useCallback(() => {
    if (Object.keys(validationRules).length === 0) {
      return true;
    }
    
    const { isValid, errors: validationErrors } = validateForm(values, validationRules);
    setErrors(validationErrors);
    
    return isValid;
  }, [values, validationRules]);
  
  // Обработчик отправки формы
  const handleSubmit = useCallback(async (e) => {
    if (e) {
      e.preventDefault();
    }
    
    // Проверяем валидность формы
    const isValid = validate();
    
    if (!isValid) {
      return;
    }
    
    setIsSubmitting(true);
    
    try {
      await onSubmit(values);
      setIsSubmitted(true);
    } catch (error) {
      console.error('Ошибка при отправке формы:', error);
      
      // Если ошибка содержит информацию о полях с ошибками
      if (error.response?.data?.errors) {
        setErrors(error.response.data.errors);
      } else if (error.message) {
        // Общая ошибка
        setErrors({ _general: error.message });
      }
    } finally {
      setIsSubmitting(false);
    }
  }, [validate, onSubmit, values]);
  
  // Сброс формы
  const resetForm = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setIsSubmitted(false);
  }, [initialValues]);
  
  // Установка всех значений формы
  const setAllValues = useCallback((newValues) => {
    setValues(newValues);
  }, []);
  
  return {
    values,
    errors,
    isSubmitting,
    isSubmitted,
    handleChange,
    setValue,
    handleSubmit,
    validate,
    resetForm,
    setAllValues
  };
};

export default useForm;
