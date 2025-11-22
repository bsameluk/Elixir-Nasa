# Elixir/Phoenix Cheatsheet

> Держи этот файл открытым при кодинге! Быстрая справка по синтаксису и частым операциям.

## Основной синтаксис

### Переменные и типы

```elixir
# Базовые типы
number = 42
float = 3.14
string = "hello"
atom = :ok
boolean = true
nil_value = nil

# Коллекции
list = [1, 2, 3]
tuple = {:ok, "result"}
map = %{name: "John", age: 30}
keyword_list = [name: "John", age: 30]

# Строки
"Hello #{name}"                    # интерполяция
"Hello" <> " " <> "World"          # конкатенация
~s(String with "quotes")           # sigil
```

### Pattern Matching

```elixir
# Присваивание
{status, result} = {:ok, 42}

# В функциях
def handle({:ok, data}), do: process(data)
def handle({:error, reason}), do: log_error(reason)

# Списки
[head | tail] = [1, 2, 3]           # head=1, tail=[2,3]
[first, second | rest] = [1,2,3,4]  # first=1, second=2, rest=[3,4]

# Maps
%{name: name} = %{name: "John", age: 30}
# name = "John"

# Игнорирование
{:ok, _} = result
[_ | tail] = list
```

### Функции

```elixir
# Анонимная функция
add = fn a, b -> a + b end
add.(2, 3)  # 5 - точка обязательна!

# Короткая форма (capture)
add = &(&1 + &2)
double = &(&1 * 2)

# Именованная функция
def greet(name), do: "Hello, #{name}"
def greet(name) do
  "Hello, #{name}"
end

# Pattern matching в функциях
def sum([]), do: 0
def sum([h | t]), do: h + sum(t)

# Guards
def drink(age) when age >= 18, do: "beer"
def drink(_), do: "juice"

# Default arguments
def greet(name, greeting \\ "Hello") do
  "#{greeting}, #{name}"
end
```

### Условия

```elixir
# if
if age >= 18, do: "adult", else: "minor"

if age >= 18 do
  "adult"
else
  "minor"
end

# case (часто используется!)
case result do
  {:ok, value} -> value
  {:error, reason} -> log_error(reason)
  _ -> "unknown"
end

# cond (цепочка условий)
cond do
  age < 13 -> "child"
  age < 18 -> "teen"
  true -> "adult"
end

# with (цепочка операций)
with {:ok, user} <- fetch_user(id),
     {:ok, posts} <- fetch_posts(user.id) do
  {:ok, %{user: user, posts: posts}}
else
  {:error, reason} -> {:error, reason}
end
```

## Работа с коллекциями (Enum)

```elixir
list = [1, 2, 3, 4, 5]

# Map
Enum.map(list, fn x -> x * 2 end)
Enum.map(list, &(&1 * 2))

# Filter
Enum.filter(list, fn x -> x > 2 end)
Enum.filter(list, &(&1 > 2))

# Reduce
Enum.reduce(list, 0, fn x, acc -> x + acc end)
Enum.reduce(list, 0, &(&1 + &2))

# Each
Enum.each(list, fn x -> IO.puts(x) end)

# Find
Enum.find(list, fn x -> x > 3 end)

# Any / All
Enum.any?(list, &(&1 > 3))
Enum.all?(list, &(&1 > 0))

# Sort
Enum.sort(list)
Enum.sort(list, :desc)
Enum.sort_by(users, & &1.age)

# Take / Drop
Enum.take(list, 3)
Enum.drop(list, 2)

# Zip
Enum.zip([1, 2], [:a, :b])  # [{1, :a}, {2, :b}]

# With index
Enum.with_index(list)  # [{1, 0}, {2, 1}, ...]

# Chunk
Enum.chunk_every(list, 2)  # [[1, 2], [3, 4], [5]]
```

## Работа со списками

```elixir
# Добавить в начало (быстро!)
[0 | list]
[0, 1 | list]

# Добавить в конец (медленно!)
list ++ [6]

# Concat
[1, 2] ++ [3, 4]  # [1, 2, 3, 4]

# Head / Tail
hd([1, 2, 3])  # 1
tl([1, 2, 3])  # [2, 3]

# Length
length(list)

# Access
Enum.at(list, 2)
List.first(list)
List.last(list)

# Update
List.replace_at(list, 1, 99)
List.update_at(list, 1, &(&1 * 2))
List.delete_at(list, 1)
```

## Работа с Maps

```elixir
map = %{name: "John", age: 30}

# Доступ
map[:name]
map.name  # только с atom keys
Map.get(map, :name)
Map.get(map, :missing, "default")
Map.fetch(map, :name)  # {:ok, "John"}
Map.fetch!(map, :name)  # "John" | raises

# Добавить/обновить
Map.put(map, :email, "john@ex.com")
%{map | age: 31}  # только для существующих ключей!

# Удалить
Map.delete(map, :age)

# Проверки
Map.has_key?(map, :name)
Map.keys(map)
Map.values(map)

# Merge
Map.merge(map1, map2)

# Update
Map.update(map, :age, 0, &(&1 + 1))
```

## Работа со строками

```elixir
# String модуль
String.length("hello")
String.upcase("hello")
String.downcase("HELLO")
String.capitalize("hello")
String.trim("  hello  ")
String.split("a,b,c", ",")
String.replace("hello", "l", "L")
String.contains?("hello", "ll")
String.starts_with?("hello", "he")
String.slice("hello", 0..2)

# Charlists vs Strings
"hello"  # string (binary)
'hello'  # charlist (list of integers)
```

## Pipe Operator

```elixir
# Вместо
result = function3(function2(function1(data)))

# Пиши
result = data
|> function1()
|> function2()
|> function3()

# Пример
[1, 2, 3, 4, 5]
|> Enum.filter(&(&1 > 2))
|> Enum.map(&(&1 * 2))
|> Enum.sum()
# 24
```

## Модули

```elixir
defmodule MyModule do
  # Атрибут модуля
  @default_name "World"
  
  # Публичная функция
  def greet(name \\ @default_name) do
    "Hello, #{name}!"
  end
  
  # Приватная функция
  defp secret do
    "shhh"
  end
end

# Использование
MyModule.greet()
MyModule.greet("John")

# Алиас
alias MyApp.Very.Long.ModuleName, as: Short
Short.function()

# Import (редко используется)
import Enum, only: [map: 2, filter: 2]
map([1, 2], &(&1 * 2))
```

## Structs

```elixir
defmodule User do
  defstruct name: nil, email: nil, age: 0
end

# Создание
user = %User{name: "John", email: "john@ex.com"}

# Доступ
user.name

# Обновление (новый struct!)
user = %{user | age: 31}

# Pattern matching
%User{name: name} = user

# Значения по умолчанию
defstruct name: "Unknown", age: 0
```

## Phoenix: Router

```elixir
scope "/", MyAppWeb do
  pipe_through :browser
  
  get "/", PageController, :home
  get "/about", PageController, :about
  
  resources "/posts", PostController
  # GET    /posts           -> index
  # GET    /posts/new       -> new
  # POST   /posts           -> create
  # GET    /posts/:id       -> show
  # GET    /posts/:id/edit  -> edit
  # PUT    /posts/:id       -> update
  # DELETE /posts/:id       -> delete
  
  # LiveView
  live "/live", MyLive
  live "/posts/:id", PostLive.Show
end

# Pipelines
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :protect_from_forgery
end
```

## Phoenix: Controller

```elixir
defmodule MyAppWeb.PostController do
  use MyAppWeb, :controller
  
  alias MyApp.Blog
  
  def index(conn, _params) do
    posts = Blog.list_posts()
    render(conn, "index.html", posts: posts)
  end
  
  def show(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    render(conn, "show.html", post: post)
  end
  
  def create(conn, %{"post" => post_params}) do
    case Blog.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Created!")
        |> redirect(to: Routes.post_path(conn, :show, post))
      
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
```

## Phoenix: LiveView

```elixir
defmodule MyAppWeb.CounterLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Count: <%= @count %></h1>
      <button phx-click="inc">+</button>
      <button phx-click="dec">-</button>
    </div>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end
end
```

## Phoenix: LiveView Events

```elixir
# Клики
<button phx-click="save">Save</button>

# Формы
<form phx-submit="create" phx-change="validate">
  <input name="title" />
</form>

# С параметрами
<button phx-click="delete" phx-value-id={@post.id}>Delete</button>

# Debounce
<input phx-change="search" phx-debounce="300" />

# Навигация
<.link navigate={~p"/posts"}>Posts</.link>
<.link patch={~p"/posts/#{@post}"}>Show</.link>

# В коде
push_navigate(socket, to: ~p"/posts")
push_patch(socket, to: ~p"/posts/#{post}")
```

## Ecto: Queries

```elixir
# Простые
Repo.all(User)
Repo.get(User, 1)
Repo.get!(User, 1)
Repo.get_by(User, email: "john@ex.com")

# Query
from(u in User, where: u.age > 18, select: u)

# Pipe syntax
User
|> where([u], u.age > 18)
|> order_by(:name)
|> limit(10)
|> Repo.all()

# Preload (для ассоциаций)
user = Repo.preload(user, :posts)
user = Repo.preload(user, [:posts, :comments])

# Join
User
|> join(:inner, [u], p in assoc(u, :posts))
|> where([u, p], p.published == true)
|> Repo.all()
```

## Ecto: Changeset

```elixir
# Schema
schema "users" do
  field :email, :string
  field :age, :integer
  timestamps()
end

# Changeset
def changeset(user, attrs) do
  user
  |> cast(attrs, [:email, :age])
  |> validate_required([:email])
  |> validate_format(:email, ~r/@/)
  |> validate_number(:age, greater_than: 0)
  |> unique_constraint(:email)
end

# CRUD
changeset = User.changeset(%User{}, attrs)
{:ok, user} = Repo.insert(changeset)
{:ok, user} = Repo.update(changeset)
{:ok, _} = Repo.delete(user)
```

## Mix Commands

```bash
# Проект
mix new my_app                      # новый проект
mix phx.new my_app                  # Phoenix проект
mix phx.new my_app --no-ecto        # без БД

# Зависимости
mix deps.get                        # установить deps
mix deps.update --all               # обновить deps

# База данных
mix ecto.create                     # создать БД
mix ecto.migrate                    # запустить миграции
mix ecto.rollback                   # откат миграции
mix ecto.reset                      # drop + create + migrate

# Генераторы
mix phx.gen.html Accounts User users email:string
mix phx.gen.live Accounts User users email:string
mix phx.gen.context Accounts User users email:string
mix phx.gen.schema Accounts.User users email:string

# Сервер
mix phx.server                      # запустить сервер
iex -S mix phx.server               # с консолью

# Тесты
mix test                            # все тесты
mix test test/my_test.exs           # конкретный файл
mix test test/my_test.exs:12        # конкретная строка

# Другое
mix format                          # форматирование кода
mix phx.routes                      # список роутов
mix compile                         # компиляция
```

## IEx (Console)

```elixir
# Запуск
iex
iex -S mix
iex -S mix phx.server

# Помощь
h Enum.map                          # документация
i "hello"                           # информация о значении
v                                   # последний результат
v(3)                                # результат из строки 3

# Перекомпиляция
recompile()

# В Phoenix
MyApp.Repo.all(User)
alias MyApp.Accounts.User
```

## Ruby → Elixir Quick Reference

| Ruby | Elixir | Описание |
|------|--------|----------|
| `arr.map { }` | `Enum.map(list, fn -> end)` | Map |
| `arr.select { }` | `Enum.filter(list, fn -> end)` | Filter |
| `arr.reduce(0) { }` | `Enum.reduce(list, 0, fn -> end)` | Reduce |
| `arr.each { }` | `Enum.each(list, fn -> end)` | Each |
| `arr.find { }` | `Enum.find(list, fn -> end)` | Find |
| `arr.any? { }` | `Enum.any?(list, fn -> end)` | Any |
| `arr.length` | `length(list)` | Length |
| `arr.first` | `List.first(list)` | First |
| `str.upcase` | `String.upcase(str)` | Upcase |
| `str.length` | `String.length(str)` | Length |
| `hash[:key]` | `map[:key]` | Map access |
| `hash.merge(other)` | `Map.merge(map, other)` | Merge |
| `nil` | `nil` | Null |
| `:symbol` | `:atom` | Symbol/Atom |
| `rescue` | `rescue` или `{:error, _}` | Error handling |

## Полезные модули stdlib

```elixir
# Enum - работа со списками
Enum.map, filter, reduce, find, sort, take, drop

# String - работа со строками
String.upcase, downcase, trim, split, replace

# Map - работа с maps
Map.get, put, delete, merge, keys, values

# List - работа со списками
List.first, last, insert_at, delete_at

# Integer - целые числа
Integer.parse("42")  # {42, ""}

# Float - float числа
Float.parse("3.14")  # {3.14, ""}
Float.round(3.14159, 2)  # 3.14

# Tuple - кортежи
elem(tuple, 0)
put_elem(tuple, 0, value)

# Keyword - keyword lists
Keyword.get(kw, :key)
Keyword.put(kw, :key, value)

# Regex
Regex.match?(~r/\d+/, "123")
Regex.run(~r/(\d+)/, "abc123")

# File
File.read("file.txt")  # {:ok, content}
File.write("file.txt", "content")

# Path
Path.join(["dir", "file.txt"])
Path.basename("/dir/file.txt")
```

## Частые паттерны

### Обработка ошибок

```elixir
# With tagged tuples
case fetch_user(id) do
  {:ok, user} -> process(user)
  {:error, reason} -> handle_error(reason)
end

# With
with {:ok, user} <- fetch_user(id),
     {:ok, posts} <- fetch_posts(user.id) do
  {:ok, %{user: user, posts: posts}}
end

# Exceptions (редко)
try do
  dangerous_operation!()
rescue
  e in RuntimeError -> handle_error(e)
end
```

### Валидация

```elixir
def validate_positive(n) when is_integer(n) and n > 0, do: {:ok, n}
def validate_positive(_), do: {:error, :invalid}

# В LiveView
def handle_event("save", params, socket) do
  case validate_and_save(params) do
    {:ok, result} ->
      socket = put_flash(socket, :info, "Saved!")
      {:noreply, socket}
    
    {:error, reason} ->
      socket = put_flash(socket, :error, reason)
      {:noreply, socket}
  end
end
```

---

**Сохрани этот файл в закладки!** Он пригодится при написании кода.

