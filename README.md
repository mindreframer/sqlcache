# Sqlcache

Very slim wrapper around `exqlite` to expose a key/value API with namespacing. Useful for local caching

## Usage

1. Add to children in `application.ex`:

```elixir
children = [
  ...
  {Sqlcache, []},
  ...
]
```

2. (Optional) - Configure root_dir for Sqlite DB file in `config.exs`

```elixir
config :sqlcache, rootdir: "/tmp/sqlcache"

```

3. Start using

```elixir
:ok == Sqlcache.clear_kind("test")
:ok == Sqlcache.put("test", "a", 1)
{:ok, 1} == Sqlcache.get("test", "a")
:ok == Sqlcache.put("test", "a", %{a: 1, b: 2})
{:ok, %{a: 1, b: 2}} == Sqlcache.get("test", "a")
:ok == Sqlcache.clear_kind("test")
{:error, nil} == Sqlcache.get("test", "a")
```

## Sqlcache.Wrapper: Function Caching Macro

`Sqlcache.Wrapper` provides a macro for easy function result caching, with namespace support and cache deletion helpers.

### Example

```elixir
defmodule MyApp.UsersCached do
  use Sqlcache.Wrapper, namespace: "user"

  # This function's result will be cached by argument
  defcached get_user(id) do
    MyApp.Users.get_user(id)
  end

  # Remove a specific cached value
  def remove_from_cache(id) do
    del(:get_user, [id])
  end
end

# Usage:
MyApp.UsersCached.get_user(123) # Calls and caches
MyApp.UsersCached.get_user(123) # Returns cached result
MyApp.UsersCached.remove_from_cache(123) # Removes from cache
```

- The macro `defcached` wraps your function to cache its result by arguments.
- Use `del/2` to remove a cached value for specific arguments.
- Namespace is configurable per module for cache separation.

## Installation

The package can be installed by adding `sqlcache` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sqlcache, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/sqlcache>.
