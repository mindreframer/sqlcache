defmodule Sqlcache.Wrapper do
  @moduledoc """
  A wrapper for the Sqlcache module.

  This module provides a macro for defining cached functions.
  It also provides a function for deleting cached values.

  ## Example

  ```elixir
  defmodule MyApp.UsersCached do
    use Sqlcache.Wrapper, namespace: "user"

    defcached get_user(id) do
      MyApp.Users.get_user(id)
    end

    def remove_from_cache(id) do
      del(:get_user, [id])
    end
  end
  ```
  """

  defmacro __using__(opts) do
    quote do
      @rest_cache_namespace unquote(opts[:namespace] || "default")
      import Sqlcache.Wrapper, only: [defcached: 2]

      def del(fun, args) do
        key = Sqlcache.Wrapper.key(fun, args)
        Sqlcache.del(@rest_cache_namespace, key)
      end
    end
  end

  defmacro defcached({name, _, args} = _fun_ast, do: body) do
    quote do
      def unquote(name)(unquote_splicing(args)) do
        key = Sqlcache.Wrapper.key(unquote(name), [unquote_splicing(args)])
        Sqlcache.Wrapper.cached(@rest_cache_namespace, key, fn -> unquote(body) end)
      end
    end
  end

  def key(fun, args), do: :erlang.phash2({fun, args})

  def cached(namespace, key, fun) do
    try do
      case Sqlcache.get(namespace, key) do
        {:ok, value} ->
          value

        _ ->
          value = fun.()

          case value do
            {:error, _} ->
              value

            _ ->
              Sqlcache.put(namespace, key, value)
              value
          end
      end
    rescue
      e ->
        reraise e, __STACKTRACE__
    end
  end

  def del(namespace, fun, args) do
    key = key(fun, args)
    Sqlcache.del(namespace, key)
  end
end
