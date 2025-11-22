# Основы языка Elixir для Ruby-разработчика

## Главные отличия от Ruby

| Аспект | Ruby | Elixir |
|--------|------|--------|
| **Парадигма** | Объектно-ориентированный | Функциональный |
| **Мутабельность** | Всё мутабельно | Всё иммутабельно |
| **Данные** | Объекты с методами | Данные и функции раздельно |
| **Null** | `nil` | `nil` (но pattern matching!) |
| **Условия** | `if/unless/case` | Pattern matching + guards |
| **Циклы** | `each/map/loop` | Рекурсия + Enum |
| **Ошибки** | Exceptions (rescue) | `{:ok, result}` / `{:error, reason}` |
| **Конкурентность** | Threads (OS) | Processes (BEAM) |

## Синтаксис: Ruby → Elixir

### 1. Переменные и типы данных

```ruby
# Ruby
name = "John"
age = 30
price = 99.99
active = true
empty = nil

# Массивы
numbers = [1, 2, 3]
mixed = [1, "two", :three]

# Хэши (Hash)
user = { name: "John", age: 30 }
user = { "name" => "John", "age" => 30 }

# Символы
status = :active
```

```elixir
# Elixir
name = "John"
age = 30
price = 99.99
active = true
empty = nil

# Списки (Lists) - linked list!
numbers = [1, 2, 3]
mixed = [1, "two", :three]

# Maps (аналог Hash)
user = %{name: "John", age: 30}
user = %{"name" => "John", "age" => 30}

# Атомы (atoms) - как символы
status = :active
```

**Важно:** В Elixir список (List) — это linked list, не массив! Доступ к элементу O(n).

### 2. Строки

```ruby
# Ruby
name = "John"
greeting = "Hello, #{name}!"
multiline = """
  Multiple
  lines
"""

# Методы строк
name.upcase        # "JOHN"
name.length        # 4
name.split("")     # ["J", "o", "h", "n"]
```

```elixir
# Elixir
name = "John"
greeting = "Hello, #{name}!"
multiline = """
  Multiple
  lines
"""

# Функции для строк (модуль String)
String.upcase(name)          # "JOHN"
String.length(name)          # 4
String.graphemes(name)       # ["J", "o", "h", "n"]
```

**Разница:** В Ruby методы вызываются на объекте, в Elixir — через модуль.

### 3. Функции vs Методы

```ruby
# Ruby - методы в классах
class Calculator
  def add(a, b)
    a + b
  end
  
  def self.multiply(a, b)
    a * b
  end
end

Calculator.new.add(2, 3)      # 5
Calculator.multiply(2, 3)     # 6
```

```elixir
# Elixir - функции в модулях
defmodule Calculator do
  # Публичная функция
  def add(a, b) do
    a + b
  end
  
  # Приватная функция
  defp subtract(a, b) do
    a - b
  end
  
  # Функция с guard
  def divide(a, b) when b != 0 do
    a / b
  end
end

Calculator.add(2, 3)          # 5
```

**Важно:** В Elixir нет классов, нет инстансов, нет `self`. Только модули и функции.

### 4. Pattern Matching — самая мощная фича!

```ruby
# Ruby - присваивание
x = 10
# x получает значение 10

# "Паттерн" через case
case response
when { success: true, data: data }
  process(data)
when { success: false, error: error }
  handle_error(error)
end
```

```elixir
# Elixir - pattern matching
x = 10
# x "матчится" с 10

# Деструктуризация
{status, result} = {:ok, 42}
# status = :ok, result = 42

# В функциях (мощно!)
def handle({:ok, data}), do: process(data)
def handle({:error, reason}), do: handle_error(reason)

# В case
case response do
  {:ok, data} -> process(data)
  {:error, reason} -> handle_error(reason)
end

# Списки
[first | rest] = [1, 2, 3, 4]
# first = 1, rest = [2, 3, 4]

# Maps
%{name: name, age: age} = %{name: "John", age: 30}
# name = "John", age = 30
```

**Pattern matching используется везде:** присваивание, функции, case, cond, with.

### 5. Условия

```ruby
# Ruby
if age >= 18
  "adult"
else
  "minor"
end

# Тернарный
result = age >= 18 ? "adult" : "minor"

# Unless
unless logged_in
  redirect_to login_path
end

# Case
case status
when :active
  "Running"
when :paused
  "Paused"
else
  "Unknown"
end
```

```elixir
# Elixir - if (но редко используется!)
if age >= 18 do
  "adult"
else
  "minor"
end

# Нет тернарного оператора

# unless тоже есть
unless logged_in do
  redirect(conn, to: "/login")
end

# Case (используется часто!)
case status do
  :active -> "Running"
  :paused -> "Paused"
  _ -> "Unknown"
end

# Cond (цепочка условий)
cond do
  age < 13 -> "child"
  age < 18 -> "teen"
  age < 65 -> "adult"
  true -> "senior"
end
```

**Идиоматично:** В Elixir предпочитают pattern matching вместо if/else.

### 6. Работа с коллекциями

```ruby
# Ruby
numbers = [1, 2, 3, 4, 5]

# Map
numbers.map { |n| n * 2 }           # [2, 4, 6, 8, 10]

# Filter
numbers.select { |n| n > 3 }        # [4, 5]

# Reduce
numbers.reduce(0) { |sum, n| sum + n }  # 15

# Each
numbers.each { |n| puts n }

# Chaining
numbers
  .select { |n| n > 2 }
  .map { |n| n * 2 }
  .sum                              # 24
```

```elixir
# Elixir
numbers = [1, 2, 3, 4, 5]

# Map
Enum.map(numbers, fn n -> n * 2 end)          # [2, 4, 6, 8, 10]
# Короткая форма
Enum.map(numbers, &(&1 * 2))                  # [2, 4, 6, 8, 10]

# Filter
Enum.filter(numbers, fn n -> n > 3 end)       # [4, 5]
Enum.filter(numbers, &(&1 > 3))               # [4, 5]

# Reduce
Enum.reduce(numbers, 0, fn n, sum -> sum + n end)  # 15

# Each
Enum.each(numbers, fn n -> IO.puts(n) end)

# Pipe operator! (читается сверху вниз)
numbers
|> Enum.filter(&(&1 > 2))
|> Enum.map(&(&1 * 2))
|> Enum.sum()                                 # 24
```

**Pipe operator `|>`** — аналог Ruby chains, но универсальный:

```elixir
# Вместо вложенных вызовов
result = func3(func2(func1(data)))

# Пишем последовательно
result = data
|> func1()
|> func2()
|> func3()
```

### 7. Функции: анонимные и именованные

```ruby
# Ruby
# Lambda
double = ->(x) { x * 2 }
double.call(5)              # 10

# Proc
multiply = proc { |a, b| a * b }
multiply.call(3, 4)         # 12

# Block
[1, 2, 3].map { |n| n * 2 }
```

```elixir
# Elixir
# Анонимная функция
double = fn x -> x * 2 end
double.(5)                  # 10 - точка обязательна!

# Короткая форма (capture)
double = &(&1 * 2)
double.(5)                  # 10

# Многострочная
multiply = fn a, b ->
  result = a * b
  result
end
multiply.(3, 4)             # 12

# В Enum
Enum.map([1, 2, 3], fn n -> n * 2 end)
Enum.map([1, 2, 3], &(&1 * 2))
```

**Важно:** Именованные функции вызываются без точки, анонимные — с точкой!

```elixir
Calculator.add(1, 2)        # именованная - без точки
my_func.(1, 2)              # анонимная - с точкой
```

### 8. Модули и структуры

```ruby
# Ruby
class User
  attr_accessor :name, :email
  
  def initialize(name, email)
    @name = name
    @email = email
  end
  
  def greet
    "Hello, #{@name}!"
  end
end

user = User.new("John", "john@example.com")
user.greet                  # "Hello, John!"
user.name = "Jane"
```

```elixir
# Elixir - Struct (структура данных)
defmodule User do
  defstruct [:name, :email]
  
  def new(name, email) do
    %User{name: name, email: email}
  end
  
  def greet(%User{name: name}) do
    "Hello, #{name}!"
  end
end

user = User.new("John", "john@example.com")
User.greet(user)            # "Hello, John!"

# Обновление (создается НОВАЯ структура!)
user2 = %{user | name: "Jane"}
```

**Разница:** 
- Ruby: объекты мутабельны, есть состояние
- Elixir: структуры иммутабельны, нет состояния

### 9. Обработка ошибок

```ruby
# Ruby - exceptions
begin
  result = dangerous_operation()
rescue StandardError => e
  handle_error(e)
ensure
  cleanup()
end

# Возврат nil при ошибке
result = find_user(id) rescue nil
```

```elixir
# Elixir - tagged tuples (идиоматично!)
case dangerous_operation() do
  {:ok, result} -> handle_success(result)
  {:error, reason} -> handle_error(reason)
end

# Exceptions (редко используются)
try do
  result = dangerous_operation!()
rescue
  e in RuntimeError -> handle_error(e)
after
  cleanup()
end

# Оператор ! = "могу упасть"
File.read("file.txt")       # {:ok, content} | {:error, reason}
File.read!("file.txt")      # content | raises exception

# Оператор with (цепочка операций)
with {:ok, user} <- find_user(id),
     {:ok, posts} <- fetch_posts(user.id),
     {:ok, result} <- process(posts) do
  {:ok, result}
else
  {:error, reason} -> {:error, reason}
end
```

**Философия:** В Elixir ошибки — это данные, не исключения.

### 10. Иммутабельность

```ruby
# Ruby - всё мутабельно
user = { name: "John", age: 30 }
user[:age] = 31             # Изменяет оригинал
user                        # { name: "John", age: 31 }

numbers = [1, 2, 3]
numbers << 4                # Изменяет оригинал
numbers                     # [1, 2, 3, 4]
```

```elixir
# Elixir - всё иммутабельно
user = %{name: "John", age: 30}
user2 = %{user | age: 31}   # Создает НОВЫЙ map
user                        # %{name: "John", age: 30} - не изменился!
user2                       # %{name: "John", age: 31}

numbers = [1, 2, 3]
numbers2 = [4 | numbers]    # Создает НОВЫЙ список
numbers                     # [1, 2, 3] - не изменился!
numbers2                    # [4, 1, 2, 3]
```

**Преимущества иммутабельности:**
- Нет side effects
- Безопасная конкурентность
- Легче тестировать
- Можно откатить состояние

### 11. Pattern Matching в функциях (мощно!)

```ruby
# Ruby - приходится использовать if/case внутри метода
def process_response(response)
  if response[:success]
    puts "Success: #{response[:data]}"
  else
    puts "Error: #{response[:error]}"
  end
end
```

```elixir
# Elixir - разные "версии" функции по паттерну!
def process_response({:ok, data}) do
  IO.puts("Success: #{data}")
end

def process_response({:error, reason}) do
  IO.puts("Error: #{reason}")
end

# Можно еще и guard conditions
def process_number(n) when n > 0 do
  "positive"
end

def process_number(n) when n < 0 do
  "negative"
end

def process_number(0) do
  "zero"
end

# Рекурсия с pattern matching
def sum([]), do: 0
def sum([head | tail]), do: head + sum(tail)

sum([1, 2, 3, 4])  # 10
```

### 12. Guards (защитные выражения)

```elixir
# Guards в функциях
def drink(age) when age >= 18, do: "🍺 Beer"
def drink(age) when age >= 0, do: "🥤 Juice"

# Guards с pattern matching
def pay(amount) when is_integer(amount) and amount > 0 do
  "Paying #{amount}"
end

# Встроенные guard функции
is_atom/1, is_binary/1, is_boolean/1
is_integer/1, is_float/1, is_number/1
is_list/1, is_map/1, is_tuple/1
is_nil/1, is_function/1
```

**Ограничения:** В guards можно использовать только чистые функции без side effects.

### 13. Работа с Maps (аналог Hash)

```ruby
# Ruby
user = { name: "John", age: 30 }
user[:name]                  # "John"
user[:email] = "john@ex.com" # Мутация
user.fetch(:name)            # "John"
user.fetch(:missing, "N/A")  # "N/A"
```

```elixir
# Elixir
user = %{name: "John", age: 30}
user[:name]                  # "John"
user.name                    # работает с atom keys!

# Обновление (новый map!)
user = Map.put(user, :email, "john@ex.com")

# Синтаксис обновления
user = %{user | age: 31}

# Доступ
Map.get(user, :name)         # "John"
Map.get(user, :missing, "N/A")  # "N/A"
Map.fetch(user, :name)       # {:ok, "John"}
Map.fetch!(user, :name)      # "John" | raises

# Проверки
Map.has_key?(user, :name)    # true
```

### 14. Рекурсия вместо циклов

```ruby
# Ruby - цикл
def factorial(n)
  result = 1
  (1..n).each { |i| result *= i }
  result
end
```

```elixir
# Elixir - рекурсия
def factorial(0), do: 1
def factorial(n) when n > 0 do
  n * factorial(n - 1)
end

# Tail recursion (оптимизация)
def factorial(n), do: factorial(n, 1)

defp factorial(0, acc), do: acc
defp factorial(n, acc) do
  factorial(n - 1, n * acc)
end
```

**Важно:** BEAM оптимизирует tail-recursion, она не расходует стек!

## Основные типы данных

| Тип | Пример | Описание |
|-----|--------|----------|
| **Integer** | `42`, `0x2A` | Целые числа (любого размера!) |
| **Float** | `3.14`, `1.0e10` | Числа с плавающей точкой |
| **Atom** | `:ok`, `:error`, `true`, `false`, `nil` | Константы, как Symbol в Ruby |
| **String** | `"hello"` | UTF-8 бинарные строки |
| **List** | `[1, 2, 3]` | Linked list |
| **Tuple** | `{:ok, 42}` | Фиксированный размер, быстрый доступ |
| **Map** | `%{key: "value"}` | Ключ-значение |
| **Struct** | `%User{name: "John"}` | Map с предопределенными ключами |
| **Binary** | `<<1, 2, 3>>` | Последовательность байтов |

## Чеклист для Rails-разработчика

✅ **Принять:** Нет классов, нет объектов, нет мутаций  
✅ **Привыкнуть:** Pattern matching везде (самая мощная фича)  
✅ **Использовать:** Pipe operator для цепочек  
✅ **Понять:** `{:ok, result}` и `{:error, reason}` вместо exceptions  
✅ **Забыть:** `for/while` циклы — только рекурсия или `Enum`  
✅ **Осознать:** Функции в модулях, не методы в классах  

## Следующий шаг

Переходи к **02-phoenix-vs-rails.md** для изучения веб-фреймворка Phoenix.

---

**Полезные ссылки:**
- [Elixir - Basic Types](https://elixir-lang.org/getting-started/basic-types.html)
- [Pattern Matching](https://elixir-lang.org/getting-started/pattern-matching.html)
- [Enum модуль](https://hexdocs.pm/elixir/Enum.html)

