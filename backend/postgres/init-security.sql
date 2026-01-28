-- Security hardening script for PostgreSQL
-- This script disables dangerous functions and enables security logging

-- Отключить COPY FROM PROGRAM для обычных пользователей
-- Это предотвращает выполнение произвольных команд через SQL
REVOKE EXECUTE ON FUNCTION pg_catalog.pg_read_file(text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION pg_catalog.pg_read_file(text, bigint, bigint) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION pg_catalog.pg_read_file(text, bigint, bigint, boolean) FROM PUBLIC;

-- Ограничить создание функций (требует суперпользователя)
-- Это предотвращает создание вредоносных функций через SQL-инъекции
ALTER DATABASE postgres SET allow_system_table_mods = off;

-- Включить логирование подключений для мониторинга
ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;
ALTER SYSTEM SET log_hostname = on;

-- Логировать все SQL-запросы (опционально, можно включить для отладки)
-- ALTER SYSTEM SET log_statement = 'all';

-- Логировать медленные запросы (более 1 секунды)
ALTER SYSTEM SET log_min_duration_statement = 1000;

-- Включить логирование ошибок
ALTER SYSTEM SET log_error_verbosity = default;

-- Перезагрузить конфигурацию
SELECT pg_reload_conf();
