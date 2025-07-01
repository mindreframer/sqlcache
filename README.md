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
