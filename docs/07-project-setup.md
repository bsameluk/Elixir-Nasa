# Установка и настройка окружения

## Установка Elixir и Erlang

### macOS

```bash
# Через Homebrew (рекомендуется)
brew install elixir

# Проверка
elixir --version
# Elixir 1.15+ (проверь актуальную версию)
# Erlang/OTP 26+
```

### Linux (Ubuntu/Debian)

```bash
# Добавить репозиторий
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update

# Установить Erlang и Elixir
sudo apt-get install esl-erlang elixir

# Проверка
elixir --version
```

### Linux (Fedora)

```bash
sudo dnf install elixir erlang

# Проверка
elixir --version
```

### Windows

1. Скачать установщик: https://elixir-lang.org/install.html#windows
2. Запустить installer
3. Проверка в PowerShell:

```powershell
elixir --version
```

### asdf (рекомендуется для разработки)

**asdf** — менеджер версий для Erlang/Elixir (как rbenv для Ruby).

```bash
# Установить asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

# Добавить в ~/.zshrc или ~/.bashrc
. "$HOME/.asdf/asdf.sh"

# Установить плагины
asdf plugin add erlang
asdf plugin add elixir

# Установить Erlang
asdf install erlang 26.1.2

# Установить Elixir
asdf install elixir 1.15.7-otp-26

# Установить глобально
asdf global erlang 26.1.2
asdf global elixir 1.15.7-otp-26

# Проверка
elixir --version
```

## Установка Phoenix

```bash
# Установить Hex (менеджер пакетов)
mix local.hex

# Установить Phoenix installer
mix archive.install hex phx_new

# Проверка
mix phx.new --version
# Phoenix v1.7.10 (проверь актуальную версию)
```

## Установка PostgreSQL (если нужна БД)

### macOS

```bash
brew install postgresql@15
brew services start postgresql@15

# Создать пользователя
psql postgres
CREATE USER postgres WITH PASSWORD 'postgres' SUPERUSER;
\q
```

### Linux

```bash
sudo apt-get install postgresql postgresql-contrib

# Создать пользователя
sudo -u postgres psql
CREATE USER postgres WITH PASSWORD 'postgres' SUPERUSER;
\q
```

### Для задачи NASA

**PostgreSQL не нужен!** Используем `--no-ecto` флаг при создании проекта.

## Создание проекта Phoenix

### С БД (обычный проект)

```bash
mix phx.new my_app
cd my_app

# Создать БД
mix ecto.create

# Запустить сервер
mix phx.server

# Открыть http://localhost:4000
```

### Без БД (для задачи NASA)

```bash
mix phx.new fuel_calculator --no-ecto --no-mailer --no-dashboard
cd fuel_calculator

# Запустить сервер
mix phx.server

# Открыть http://localhost:4000
```

**Флаги:**
- `--no-ecto` — без БД
- `--no-mailer` — без email
- `--no-dashboard` — без LiveDashboard
- `--no-gettext` — без интернационализации

## Структура нового проекта

```
fuel_calculator/
├── _build/              # Скомпилированные файлы
├── assets/              # Frontend (JS, CSS)
│   ├── css/
│   ├── js/
│   └── vendor/
├── config/              # Конфигурация
│   ├── config.exs       # Общая конфигурация
│   ├── dev.exs          # Development
│   ├── prod.exs         # Production
│   └── test.exs         # Testing
├── deps/                # Зависимости (как node_modules)
├── lib/
│   ├── fuel_calculator/       # Бизнес-логика
│   │   └── application.ex     # OTP Application
│   └── fuel_calculator_web/   # Web слой
│       ├── controllers/
│       ├── components/        # UI компоненты (Phoenix 1.7+)
│       ├── endpoint.ex        # HTTP endpoint
│       ├── router.ex          # Routes
│       └── gettext.ex         # i18n
├── priv/                # Приватные файлы
│   ├── static/          # Статика (images, fonts)
│   └── gettext/         # Переводы
├── test/                # Тесты
│   ├── fuel_calculator/
│   ├── fuel_calculator_web/
│   └── test_helper.exs
├── .formatter.exs       # Форматтер
├── .gitignore
├── mix.exs              # Конфигурация проекта (как Gemfile)
└── README.md
```

## Основные команды

### Запуск сервера

```bash
# Обычный режим
mix phx.server

# С консолью IEx
iex -S mix phx.server

# На другом порту
PORT=4001 mix phx.server
```

### Работа с зависимостями

```bash
# Установить зависимости
mix deps.get

# Обновить зависимости
mix deps.update --all

# Показать дерево зависимостей
mix deps.tree

# Очистить зависимости
mix deps.clean --all
```

### База данных (если используется Ecto)

```bash
# Создать БД
mix ecto.create

# Удалить БД
mix ecto.drop

# Создать миграцию
mix ecto.gen.migration create_users

# Запустить миграции
mix ecto.migrate

# Откат последней миграции
mix ecto.rollback

# Откат всех миграций
mix ecto.rollback --all

# Пересоздать БД (drop + create + migrate)
mix ecto.reset

# Запустить seeds
mix run priv/repo/seeds.exs
```

### Тестирование

```bash
# Запустить все тесты
mix test

# Конкретный файл
mix test test/fuel_calculator/calculator_test.exs

# Конкретный тест (по номеру строки)
mix test test/fuel_calculator/calculator_test.exs:12

# С выводом
mix test --trace

# Coverage
mix test --cover
```

### Генераторы

```bash
# HTML CRUD (контроллер + views + templates)
mix phx.gen.html Accounts User users name:string email:string

# LiveView CRUD
mix phx.gen.live Accounts User users name:string email:string

# Context (бизнес-логика + схема)
mix phx.gen.context Accounts User users name:string email:string

# Только схема
mix phx.gen.schema Accounts.User users name:string email:string

# JSON API
mix phx.gen.json Accounts User users name:string email:string

# LiveView (пустой)
mix phx.gen.live Accounts Mission missions

# Channel (WebSocket)
mix phx.gen.channel Room
```

### Другие команды

```bash
# Показать routes
mix phx.routes

# Форматирование кода
mix format

# Компиляция
mix compile

# Очистка
mix clean

# Интерактивная консоль
iex -S mix

# Запустить скрипт
mix run script.exs

# Документация
mix docs
```

## IEx (Interactive Elixir)

```bash
# Запустить IEx
iex

# С проектом
iex -S mix

# С Phoenix сервером
iex -S mix phx.server
```

### Полезные команды в IEx

```elixir
# Помощь
h                           # общая помощь
h Enum.map                  # помощь по функции

# Информация
i "hello"                   # информация о значении
i [1, 2, 3]

# История
v                           # последний результат
v(3)                        # результат из строки 3

# Перекомпиляция
recompile()

# Выход
Ctrl+C Ctrl+C               # или
System.halt()

# Очистить экран
clear

# Автокомплит
Enum.<Tab>                  # покажет все функции
```

### Работа с приложением в IEx

```elixir
# Алиасы
alias MyApp.Accounts.User
alias MyApp.Repo

# Вызов функций
User |> Repo.all()
Repo.get(User, 1)

# Reload модуля
r MyModule

# Список процессов
Process.list()

# Информация о процессе
Process.info(self())
```

## Настройка IDE

### Visual Studio Code (рекомендуется)

**Установить расширения:**

1. **ElixirLS** — LSP для Elixir (автокомплит, go to definition, etc)
2. **Phoenix Framework** — сниппеты для Phoenix
3. **vscode-elixir** — подсветка синтаксиса

**settings.json:**

```json
{
  "elixirLS.dialyzerEnabled": false,
  "elixirLS.fetchDeps": false,
  "editor.formatOnSave": true,
  "[elixir]": {
    "editor.defaultFormatter": "JakeBecker.elixir-ls",
    "editor.insertSpaces": true,
    "editor.tabSize": 2
  }
}
```

### Zed (новый, быстрый)

Elixir поддержка из коробки с LSP.

### Vim/Neovim

```vim
" Плагины
Plug 'elixir-editors/vim-elixir'
Plug 'mhinz/vim-mix-format'

" Автоформат при сохранении
let g:mix_format_on_save = 1
```

### IntelliJ IDEA / RubyMine

**IntelliJ Elixir plugin** — полная поддержка Elixir.

### Emacs

```elisp
;; Alchemist + elixir-mode
(use-package elixir-mode)
(use-package alchemist)
```

## Настройка форматтера

```elixir
# .formatter.exs (уже создан в проекте)
[
  import_deps: [:phoenix],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
```

```bash
# Форматирование
mix format

# Проверка без изменений
mix format --check-formatted
```

## Git setup

```bash
git init
git add .
git commit -m "Initial commit"

# .gitignore уже создан Phoenix
```

**.gitignore** включает:
- `/_build/`
- `/deps/`
- `/priv/static/`
- `*.beam`
- `.elixir_ls/`

## Полезные зависимости

Добавить в `mix.exs`:

```elixir
defp deps do
  [
    {:phoenix, "~> 1.7.10"},
    {:phoenix_live_view, "~> 0.20.0"},
    
    # Development
    {:phoenix_live_reload, "~> 1.4", only: :dev},
    
    # Testing
    {:floki, ">= 0.30.0", only: :test},
    
    # Полезные
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},  # Линтер
    {:dialyxir, "~> 1.4", only: [:dev], runtime: false},      # Type checker
    {:ex_doc, "~> 0.30", only: :dev, runtime: false},         # Документация
  ]
end
```

После изменения `mix.exs`:

```bash
mix deps.get
```

## Проверка установки

```bash
# Версии
elixir --version
mix --version
mix phx.new --version

# Создать тестовый проект
mix phx.new test_app --no-ecto
cd test_app

# Установить зависимости
mix deps.get

# Запустить
mix phx.server

# Открыть http://localhost:4000
# Должна открыться Phoenix welcome page
```

Если видишь страницу приветствия Phoenix — всё работает! 🎉

## Troubleshooting

### Проблема: `mix: command not found`

**Решение:** Добавить Elixir в PATH.

```bash
# macOS/Linux
export PATH="$PATH:/path/to/elixir/bin"

# Добавить в ~/.zshrc или ~/.bashrc
echo 'export PATH="$PATH:/path/to/elixir/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Проблема: `Could not compile dependency`

**Решение:** Очистить зависимости и пересобрать.

```bash
mix deps.clean --all
mix deps.get
mix deps.compile
```

### Проблема: `Port 4000 already in use`

**Решение:** Изменить порт или убить процесс.

```bash
# Изменить порт
PORT=4001 mix phx.server

# Или убить процесс на порту 4000
lsof -ti:4000 | xargs kill -9
```

### Проблема: `Postgrex.Error` (если используется БД)

**Решение:** Проверить PostgreSQL.

```bash
# Запущен ли PostgreSQL?
brew services list  # macOS
sudo service postgresql status  # Linux

# Создать пользователя
psql postgres
CREATE USER postgres WITH PASSWORD 'postgres' SUPERUSER;
```

### Проблема: ElixirLS не работает в VSCode

**Решение:**

1. Удалить `.elixir_ls/` в проекте
2. Перезапустить VSCode
3. Дождаться компиляции

```bash
rm -rf .elixir_ls
```

## Быстрый старт для задачи NASA

```bash
# 1. Создать проект
mix phx.new fuel_calculator --no-ecto --no-mailer --no-dashboard
cd fuel_calculator

# 2. Установить зависимости
mix deps.get

# 3. Запустить сервер
mix phx.server

# 4. Открыть http://localhost:4000

# 5. Начать кодить!
# - Создать lib/fuel_calculator/calculator.ex
# - Создать lib/fuel_calculator_web/live/mission_live.ex
# - Добавить route в router.ex
# - Написать тесты в test/
```

## Полезные ресурсы

- **Документация:**
  - [Elixir Docs](https://elixir-lang.org/docs.html)
  - [Phoenix Docs](https://hexdocs.pm/phoenix/)
  - [LiveView Docs](https://hexdocs.pm/phoenix_live_view/)

- **Туториалы:**
  - [Elixir School](https://elixirschool.com/ru) — на русском!
  - [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html)

- **Сообщество:**
  - [Elixir Forum](https://elixirforum.com/)
  - [ElixirLang Slack](https://elixir-slackin.herokuapp.com/)
  - [Reddit r/elixir](https://reddit.com/r/elixir)

## Следующие шаги

1. ✅ Установка завершена
2. ✅ Проект создан
3. 📖 Вернись к документации:
   - **00-overview.md** — общий обзор
   - **01-language-basics.md** — синтаксис языка
   - **02-phoenix-vs-rails.md** — Phoenix framework
   - **03-liveview.md** — LiveView для интерактивности
   - **05-nasa-task-breakdown.md** — разбор задачи NASA
   - **06-cheatsheet.md** — держи под рукой при кодинге

4. 🚀 **Начинай кодить задачу NASA!**

---

**Удачи с изучением Elixir!** 🎉

