# Инструменты проекта

Документация по всем используемым инструментам и библиотекам в проекте.

## Основной стек

### Rails 8.0.2

Веб-фреймворк. Используется в режиме `api_only: false` для поддержки как API, так и веб-интерфейса.

**Конфигурация:**

- Время: `Moscow` (UTC для БД)
- Локализация: `ru`
- Middleware: `Rack::Attack` подключен глобально

**Где используется:**

- Весь проект построен на Rails
- Контроллеры в `app/controllers/`
- Модели в `app/models/`
- Конфигурация в `config/`

---

### PostgreSQL

База данных. Используется через гем `pg`.

**Конфигурация:**

- Версия: 16 (в Docker)
- Подключение через `DATABASE_URL` или `config/database.yml`

**Где используется:**

- Все модели ActiveRecord
- Миграции в `db/migrate/`
- Схема в `db/schema.rb`

**Полезные команды:**

```bash
# Подключиться к БД через docker-compose
docker-compose exec db psql -U project3_1 -d project3_1_production

# Создать миграцию
rails generate migration AddFieldToTable

# Запустить миграции
rails db:migrate

# Откатить последнюю миграцию
rails db:rollback
```

---

## Аутентификация и авторизация

### JWT (JSON Web Tokens)

Аутентификация через токены. Гем `jwt`.

**Как работает:**

- Токены выдаются при логине/регистрации
- Хранятся в cookies (`token`) для веб-интерфейса
- Передаются в заголовке `Authorization` для API
- Секреты ротируются через `JwtSecretService`

**Где используется:**

- `app/controllers/concerns/jwt_helper.rb` - кодирование/декодирование
- `app/services/jwt_secret_service.rb` - управление секретами
- `app/controllers/api/v1/auth_controller.rb` - API аутентификация
- `app/controllers/auth_controller.rb` - веб аутентификация

**Конфигурация:**

- Секреты в `Rails.cache` (ключ `jwt_secret:current`)
- Ротация каждые 30 дней (настраивается через `AppConfig::JWT.rotation_interval_days`)
- TTL токена: 168 часов (7 дней)

**Полезные rake задачи:**

```bash
# Ротация секрета вручную
rails jwt:rotate

# Показать текущий секрет (только для админов)
rails jwt:show_secret
```

---

### CanCanCan

Авторизация (кто что может делать). Гем `cancancan`.

**Как работает:**

- Правила в `app/models/ability.rb`
- Используется через `authorize!` в контроллерах
- Роли: `user`, `admin`

**Где используется:**

- Все админ-контроллеры (`app/controllers/admin/*`)
- Проверка прав доступа к ресурсам

**Примеры:**

```ruby
# В контроллере
authorize! :read, Week

# В модели Ability
can :read, Week, published_at: ..Time.current, expires_at: Time.current..
can :manage, :all if user.admin?
```

---

## Пагинация

### Pagy

Быстрая пагинация. Гем `pagy`.

**Как работает:**

- Используется через `pagy` helper в контроллерах
- Возвращает объект `@pagy` и коллекцию данных
- Поддержка Bootstrap стилей

**Где используется:**

- API контроллеры (`app/controllers/api/v1/*`)
- Конфигурация в `config/initializers/pagy.rb`

**Пример:**

```ruby
@pagy, records = pagy(Model.all)
render_success(data: records, pagy: @pagy)
```

**Настройки:**

- По умолчанию: 20 элементов на страницу
- Можно переопределить через `params[:per_page]`

---

## Безопасность

### Rack::Attack

Rate limiting (защита от DDoS и брутфорса). Гем `rack-attack`.

**Как работает:**

- Middleware, подключен глобально
- Использует `Rails.cache` для хранения счетчиков
- Блокирует по IP адресу

**Где настроено:**

- `config/initializers/rack_attack.rb`

**Лимиты:**

- `/api/v1/auth/resend` - 5 запросов в час
- `/auth/resend` - 5 запросов в час
- `/api/v1/auth/password/forgot` - 5 запросов в час
- `/auth/forgot` - 5 запросов в час
- `/api/v1/auth/password/reset` - 5 запросов в час
- `/auth/reset` - 5 запросов в час
- Все auth endpoints - 20 запросов в час с одного IP

**Ответ при превышении:**

- HTTP 429
- Заголовки `X-RateLimit-*`
- JSON с сообщением об ошибке

**Как проверить:**

```bash
# В логах будет видно блокировки
tail -f log/development.log | grep "rack.attack"
```

---

### Rack::Cors

CORS (Cross-Origin Resource Sharing). Гем `rack-cors`.

**Как работает:**

- Разрешает запросы с определенных доменов
- Настроено только для `/api/*` endpoints

**Где настроено:**

- `config/initializers/cors.rb`

**Конфигурация:**

- В development: `localhost:3000`, `127.0.0.1:3000`
- В production: через `ALLOWED_CORS_ORIGINS` (список через запятую)
- Поддержка credentials (cookies)
- Max age: 86400 секунд (24 часа)

**Пример:**

```bash
# В .env или переменных окружения
ALLOWED_CORS_ORIGINS=https://example.com,https://app.example.com
```

---

### Brakeman

Статический анализ безопасности. Гем `brakeman`.

**Как использовать:**

```bash
# Запустить проверку
bin/brakeman

# Или через rake
rake brakeman:run
```

**Что проверяет:**

- SQL injection
- XSS уязвимости
- Mass assignment
- Небезопасные редиректы
- И другие известные проблемы безопасности

**Отчет:**

- Выводится в консоль
- Можно сохранить в файл: `brakeman -o report.html`

---

## Мониторинг и логирование

### Sentry

Отслеживание ошибок и мониторинг производительности. Гемы `sentry-ruby`, `sentry-rails`.

**Как работает:**

- Автоматически ловит исключения в production/staging
- Отправляет трейсы производительности
- Фильтрует чувствительные данные

**Где настроено:**

- `config/initializers/sentry.rb`
- Документация: `docs/SENTRY_SETUP.md`

**Конфигурация:**

- DSN через `SENTRY_DSN`
- Release через `SENTRY_RELEASE` или git commit
- Sample rate для трейсов: 10% (0.1)
- Sample rate для профилирования: 0% (отключено)

**Что фильтруется:**

- Пароли (`password`, `password_confirmation`, `current_password`)
- Cookies не отправляются
- Игнорируются: 404, CSRF ошибки, Rack::Attack блокировки

**Что отправляется:**

- User ID (если доступен)
- Request ID (для трейсинга)
- Breadcrumbs (логи, HTTP запросы)

**Как использовать:**

```ruby
# Вручную отправить ошибку
Sentry.capture_exception(exception)

# Добавить контекст
Sentry.set_user(id: user.id)
Sentry.set_tags(request_id: request_id)
```

---

## Фоновые задачи

### Solid Queue

Очередь задач на базе PostgreSQL. Гем `solid_queue`.

**Как работает:**

- Задачи хранятся в БД (таблица `solid_queue_jobs`)
- Запускается отдельным процессом
- Не интегрирован в Puma (из-за совместимости)

**Где используется:**

- `app/jobs/jwt_secret_rotation_job.rb` - ротация JWT секретов
- Запуск через `bin/rails solid_queue:start`

**Конфигурация:**

- `config/queue.yml` - настройки очереди
- `config/recurring.yml` - периодические задачи
- `db/queue_schema.rb` - схема таблиц

**Запуск:**

```bash
# В development
bin/rails solid_queue:start

# В production (через docker-compose)
docker-compose up worker

# Или через Kamal
kamal app exec worker "bin/rails solid_queue:start"
```

**Полезные команды:**

```bash
# Посмотреть задачи в очереди
rails runner "puts SolidQueue::Job.count"

# Очистить завершенные задачи
rails runner "SolidQueue::Job.finished.delete_all"
```

---

## Кеширование

### Solid Cache

Кеш на базе PostgreSQL. Гем `solid_cache`.

**Как работает:**

- Хранит данные в таблице `solid_cache_entries`
- Используется для `Rails.cache`
- Автоматическая очистка старых записей

**Где используется:**

- JWT секреты (`JwtSecretService`)
- Rack::Attack счетчики
- Любые `Rails.cache.write/read`

**Конфигурация:**

- Схема в `db/schema.rb`
- Настройки в `config/environments/*.rb`

**Примеры:**

```ruby
# Записать
Rails.cache.write('key', 'value', expires_in: 1.hour)

# Прочитать
Rails.cache.read('key')

# Очистить все
Rails.cache.clear
```

---

## Веб-сервер

### Puma

Многопоточный веб-сервер. Гем `puma`.

**Конфигурация:**

- `config/puma.rb`
- Потоки: 3 (настраивается через `RAILS_MAX_THREADS`)
- Порт: 3000 (настраивается через `PORT`)

**Где используется:**

- Запуск через `bin/rails server`
- В production через Thruster (см. ниже)

**Настройки:**

```bash
# Изменить количество потоков
RAILS_MAX_THREADS=5 bin/rails server

# Изменить порт
PORT=8080 bin/rails server
```

---

### Thruster

HTTP asset caching и компрессия для Puma. Гем `thruster`.

**Как работает:**

- Обертка над Puma
- Кеширует статические файлы
- Сжимает ответы

**Где используется:**

- В production через `bin/thrust`
- Dockerfile: `CMD ["./bin/thrust", "./bin/rails", "server"]`

**Запуск:**

```bash
./bin/thrust ./bin/rails server
```

---

## Тестирование

### RSpec

Фреймворк для тестов. Гем `rspec-rails`.

**Структура:**

- Тесты в `spec/`
- Модели: `spec/models/`
- Контроллеры: `spec/requests/`
- Сервисы: `spec/services/`
- Хелперы: `spec/support/`

**Запуск:**

```bash
# Все тесты
bundle exec rspec

# Конкретный файл
bundle exec rspec spec/models/user_spec.rb

# С покрытием
bundle exec rspec --format documentation

# Только падающие
bundle exec rspec --only-failures
```

**Конфигурация:**

- `spec/spec_helper.rb` - общие настройки
- `spec/rails_helper.rb` - Rails-специфичные настройки
- `spec/support/` - кастомные хелперы

**Полезные хелперы:**

- `spec/support/jwt_helper.rb` - создание тестовых JWT токенов

---

## Документация API

### Rswag (Swagger)

Автоматическая документация API. Гемы `rswag`, `rswag-api`, `rswag-ui`.

**Как работает:**

- Swagger UI доступен на `/api-docs`
- YAML файлы в `swagger/v1/`
- Генерируется из тестов (опционально)

**Где настроено:**

- `config/initializers/rswag_ui.rb` - UI конфигурация
- `config/initializers/rswag_api.rb` - API конфигурация
- `config/routes.rb` - монтирование engines

**Доступ:**

- UI: `http://localhost:3000/api-docs`
- YAML: `http://localhost:3000/api-docs/v1/swagger.yaml`

**Файлы:**

- `swagger/v1/swagger.yaml` - основная спецификация
- `swagger/v1/achievements.yaml` - спецификация achievements

---

## Деплой

### Kamal

Деплой через Docker. Гем `kamal`.

**Как работает:**

- Собирает Docker образ
- Деплоит на сервер
- Управляет контейнерами

**Конфигурация:**

- `config/deploy.yml` - настройки деплоя
- `Dockerfile` - образ приложения

**Команды:**

```bash
# Деплой
kamal deploy

# Показать конфигурацию
kamal app config

# Выполнить команду на сервере
kamal app exec "rails console"

# Логи
kamal app logs
```

**Структура:**

- `web` - веб-сервер (Puma через Thruster)
- `worker` - фоновые задачи (Solid Queue)
- `db` - PostgreSQL (accessory)

---

### Docker

Контейнеризация приложения.

**Файлы:**

- `Dockerfile` - образ приложения
- `docker-compose.yml` - локальная разработка
- `bin/docker-entrypoint` - точка входа

**Сборка:**

```bash
# Собрать образ
docker build -t project3_1 .

# Запустить через docker-compose
docker-compose up

# Только БД
docker-compose up db
```

**Структура docker-compose:**

- `web` - приложение (порт 3000->80)
- `worker` - фоновые задачи
- `db` - PostgreSQL (порт 5432)

---

## Линтинг и форматирование

### Rubocop Rails Omakase

Стиль кода от команды Rails. Гем `rubocop-rails-omakase`.

**Как использовать:**

```bash
# Проверить код
bin/rubocop

# Автоисправление
bin/rubocop -a

# Проверить конкретный файл
bin/rubocop app/models/user.rb
```

**Конфигурация:**

- Использует стандартные правила Rails
- Настройки в `.rubocop.yml` (если есть)

---

## Другие инструменты

### Bootsnap

Ускорение загрузки приложения. Гем `bootsnap`.

**Как работает:**

- Кеширует загрузку файлов
- Предкомпилирует код
- Автоматически включен

**Где используется:**

- Автоматически при запуске Rails
- Предкомпиляция в Dockerfile

---

### BCrypt

Хеширование паролей. Гем `bcrypt`.

**Как работает:**

- Используется через `has_secure_password` в моделях
- Автоматическое хеширование при сохранении

**Где используется:**

- `app/models/user.rb` - модель пользователя

---

### Faker

Генерация тестовых данных. Гем `faker`.

**Где используется:**

- В тестах для создания фиктивных данных
- В seed файлах (`db/seeds/mock.rb`)

**Пример:**

```ruby
User.create!(
  email: Faker::Internet.email,
  name: Faker::Name.name
)
```

---

### Dotenv Rails

Загрузка переменных окружения из `.env`. Гем `dotenv-rails`.

**Как работает:**

- Загружает `.env` файл при запуске
- Только в development/test

**Использование:**

```bash
# Создать .env файл
echo "DATABASE_URL=postgresql://localhost/project3_1_dev" > .env
```

---

## Файлы и хранилище

### Active Storage

Загрузка и хранение файлов. Встроено в Rails.

**Как работает:**

- Файлы хранятся локально в `storage/` (development/test)
- Можно настроить S3, GCS, Azure (production)
- Автоматическая генерация превью и вариантов

**Где используется:**

- Аватары пользователей (`app/models/user.rb`)
- Конфигурация в `config/storage.yml`

**Конфигурация:**

- Development/test: локальное хранилище (`Disk`)
- Production: можно настроить S3/GCS/Azure через credentials

**Примеры:**

```ruby
# В модели
has_one_attached :avatar

# В контроллере
user.avatar.attach(params[:avatar])

# В представлении
image_tag user.avatar if user.avatar.attached?
```

**Настройка для production:**

```bash
# Редактировать credentials
rails credentials:edit

# Добавить AWS ключи
aws:
  access_key_id: YOUR_KEY
  secret_access_key: YOUR_SECRET
```

---

## Email

### ActionMailer

Отправка email. Встроено в Rails.

**Как работает:**

- Mailers в `app/mailers/`
- Views в `app/views/*_mailer/`
- SMTP настройки в `config/initializers/action_mailer_smtp.rb`

**Где используется:**

- `app/mailers/verification_mailer.rb` - код верификации email
- `app/mailers/reset_password_mailer.rb` - сброс пароля

**Конфигурация:**

- SMTP через `SmtpConfigService`
- Настройки через `AppConfig::Email`
- Credentials: `email.default_username`, `email.default_password`

**Примеры:**

```ruby
# Отправить письмо
VerificationMailer.verification_code(user).deliver_now

# Асинхронно
VerificationMailer.verification_code(user).deliver_later
```

**Настройки SMTP:**

- Порт: 587 (настраивается через `SMTP_PORT`)
- Username/password через credentials или ENV
- Автоматическая настройка через `SmtpConfigService`

---

## Периодические задачи

### Recurring Jobs (Solid Queue)

Периодические задачи через Solid Queue.

**Как работает:**

- Конфигурация в `config/recurring.yml`
- Задачи выполняются по расписанию
- Использует cron-подобный синтаксис

**Где настроено:**

- `config/recurring.yml` - расписание задач
- `config/initializers/schedule.rb` - общие настройки

**Примеры расписания:**

```yaml
production:
  clear_solid_queue_finished_jobs:
    command: 'SolidQueue::Job.clear_finished_in_batches(...)'
    schedule: every hour at minute 12
```

**Формат расписания:**

- `every hour` - каждый час
- `every day at 3am` - каждый день в 3:00
- `every monday at 9am` - каждый понедельник в 9:00
- `at 5am every day` - каждый день в 5:00

**Текущие задачи:**

- Очистка завершенных задач Solid Queue (каждый час в 12 минут)

---

## Heroku (Procfile)

### Procfile

Конфигурация для Heroku или других PaaS.

**Структура:**

```
web: bin/rails server -p $PORT
worker: bin/rails solid_queue:start
```

**Процессы:**

- `web` - веб-сервер (Puma)
- `worker` - фоновые задачи (Solid Queue)

**Использование:**

- Heroku автоматически читает Procfile
- Можно запустить локально: `foreman start`

---

## Полезные команды

### Разработка

```bash
# Запустить сервер
bin/rails server

# Запустить консоль
bin/rails console

# Запустить миграции
bin/rails db:migrate

# Запустить тесты
bundle exec rspec

# Проверить безопасность
bin/brakeman

# Проверить стиль кода
bin/rubocop
```

### Docker

```bash
# Запустить все сервисы
docker-compose up

# Только БД
docker-compose up db

# Выполнить команду в контейнере
docker-compose exec web rails console

# Пересобрать образ
docker-compose build
```

### Kamal

```bash
# Деплой
kamal deploy

# Логи
kamal app logs

# Консоль на сервере
kamal app exec "rails console"

# Остановить
kamal app stop
```

---

## Переменные окружения

### Обязательные

- `RAILS_MASTER_KEY` - ключ для расшифровки credentials
- `DATABASE_URL` - подключение к БД

### Опциональные

- `PORT` - порт для Puma (по умолчанию 3000)
- `RAILS_MAX_THREADS` - количество потоков (по умолчанию 3)
- `ALLOWED_CORS_ORIGINS` - разрешенные домены для CORS
- `SENTRY_DSN` - DSN для Sentry
- `SENTRY_RELEASE` - версия релиза
- `JWT_ISSUER` - issuer для JWT токенов
- `JWT_AUDIENCE` - audience для JWT токенов
- `JWT_TOKEN_TTL_HOURS` - время жизни токена (по умолчанию 168)
- `JWT_SECRET_TTL_DAYS` - время жизни секрета (по умолчанию 90)
- `JWT_ROTATION_INTERVAL_DAYS` - интервал ротации (по умолчанию 30)

Полный список настроек в `config/initializers/app_config.rb`.
