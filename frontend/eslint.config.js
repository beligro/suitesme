// eslint.config.js
import js from '@eslint/js';
import globals from 'globals';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';


export default [
  {
    // Игнорируем билд-артефакты
    ignores: ['dist', 'build', '.next', 'node_modules'],
  },
  {
    files: ['**/*.{js,jsx,ts,tsx}'],

    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },

    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },

    rules: {
      // Базовые рекомендации JS
      ...js.configs.recommended.rules,
      'no-undef': 'error',
      // React Hooks правила
      ...reactHooks.configs.recommended.rules,

      // Разрешить экспорт только компонентов (для HMR)
      'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],

      // Неиспользуемые переменные, игнорировать заглавные константы
      'no-unused-vars': ['error', { varsIgnorePattern: '^[A-Z_]', argsIgnorePattern: '^_' }],

      // Прочие полезные штуки, если нужно:
      // 'eqeqeq': ['warn', 'always'],
      // 'no-console': 'warn',
      // 'no-debugger': 'error',
    },
  },
];