/**
 * Утилиты для валидации форм
 */

// Валидация email
export const isValidEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };
  
  // Валидация пароля (минимум 6 символов)
  export const isValidPassword = (password) => {
    return password && password.length >= 6;
  };
  
  // Проверка совпадения паролей
  export const doPasswordsMatch = (password, confirmPassword) => {
    return password === confirmPassword;
  };
  
  // Проверка, что строка не пустая
  export const isNotEmpty = (value) => {
    return value && value.trim().length > 0;
  };
  
  // Валидация даты (проверка, что дата не в будущем)
  export const isValidDate = (dateString) => {
    if (!dateString) return false;
    
    const inputDate = new Date(dateString);
    const today = new Date();
    
    return inputDate instanceof Date && !isNaN(inputDate) && inputDate <= today;
  };
  
  // Валидатор формы - принимает объект с данными и правилами валидации
  export const validateForm = (data, rules) => {
    const errors = {};
    
    Object.keys(rules).forEach(field => {
      const fieldRules = rules[field];
      const value = data[field];
      
      // Проверяем каждое правило для поля
      fieldRules.forEach(rule => {
        // Если уже есть ошибка для этого поля, пропускаем остальные проверки
        if (errors[field]) return;
        
        switch (rule.type) {
          case 'required':
            if (!isNotEmpty(value)) {
              errors[field] = rule.message || 'Это поле обязательно';
            }
            break;
            
          case 'email':
            if (value && !isValidEmail(value)) {
              errors[field] = rule.message || 'Некорректный формат email';
            }
            break;
            
          case 'minLength':
            if (value && value.length < rule.value) {
              errors[field] = rule.message || `Минимальная длина ${rule.value} символов`;
            }
            break;
            
          case 'match':
            if (value !== data[rule.field]) {
              errors[field] = rule.message || 'Значения не совпадают';
            }
            break;
            
          case 'date':
            if (value && !isValidDate(value)) {
              errors[field] = rule.message || 'Некорректная дата';
            }
            break;
            
          case 'custom':
            if (rule.validator && !rule.validator(value, data)) {
              errors[field] = rule.message || 'Некорректное значение';
            }
            break;
            
          default:
            break;
        }
      });
    });
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  };
  
  // Пример использования:
  /*
  const validationRules = {
    email: [
      { type: 'required', message: 'Email обязателен' },
      { type: 'email', message: 'Некорректный формат email' }
    ],
    password: [
      { type: 'required', message: 'Пароль обязателен' },
      { type: 'minLength', value: 6, message: 'Пароль должен содержать минимум 6 символов' }
    ],
    password_confirm: [
      { type: 'required', message: 'Подтверждение пароля обязательно' },
      { type: 'match', field: 'password', message: 'Пароли не совпадают' }
    ]
  };
  
  const { isValid, errors } = validateForm(formData, validationRules);
  */
  