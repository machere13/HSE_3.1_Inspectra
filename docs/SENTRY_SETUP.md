# Sentry Error Reporting Setup

Sentry интегрирован для отслеживания ошибок и мониторинга производительности.

SENTRY_DSN=https://your-dsn@sentry.io/project-id

# Версия релиза (для отслеживания, какая версия вызвала ошибку)

SENTRY_RELEASE=1.0.0

# Sample rate для performance monitoring (0.0 - 1.0)

SENTRY_TRACES_SAMPLE_RATE=0.1

# Sample rate для profiling (0.0 - 1.0)

SENTRY_PROFILES_SAMPLE_RATE=0.0

## Что отслеживается

- Все необработанные исключения в контроллерах
- Ошибки в background jobs (через Active Job)
- Performance monitoring (транзакции)
- Контекст пользователя (user_id) автоматически добавляется

## Что фильтруется

- Пароли и чувствительные данные автоматически фильтруются
- Некоторые исключения игнорируются (404, CSRF и т.д.)
- Cookies не отправляются
