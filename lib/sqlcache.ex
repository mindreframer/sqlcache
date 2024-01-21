defmodule Sqlcache do
  alias Exqlite.Basic
  alias Sqlcache.Compressor
  use GenServer

  def data_dir do
    Application.get_env(:sqlcache, :datadir, Sqlcache.Config.default_datadir())
  end

  def init(arg) do
    {:ok, conn} = Exqlite.Basic.open(Path.join(data_dir(), "sqlcache.db"))
    init_schema(conn)
    :persistent_term.put(:cache_conn, conn)
    {:ok, arg}
  end

  def init_schema(conn) do
    [
      "create table if not exists cache (key string primary key, value text, kind text, ts text)",
      "create index if not exists cache_kind_idx on cache(kind);"
    ]
    |> Enum.each(fn stmt -> :ok = Exqlite.Sqlite3.execute(conn.db, stmt) end)
  end

  def conn do
    :persistent_term.get(:cache_conn)
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def put(kind, k, v) do
    v = Compressor.compress(v)
    ts = DateTime.utc_now() |> DateTime.to_unix(:microsecond)

    case query("insert or replace into cache(key, value, kind, ts) values (?, ?, ?, ?)", [
           k,
           v,
           kind,
           ts
         ]) do
      {:ok, [], []} -> :ok
    end
  end

  def get(kind, k) do
    case query("select value from cache where key =  ? and kind = ?", [k, kind]) do
      {:ok, [], ["value"]} -> {:error, nil}
      {:ok, [[val]], ["value"]} -> {:ok, Compressor.uncompress(val)}
    end
  end

  def del(kind, k) do
    case query("delete from cache where key =  ? and kind = ?", [k, kind]) do
      {:ok, [], []} -> :ok
    end
  end

  def clear_kind(kind) do
    case query("delete from cache where kind = ?", [kind]) do
      {:ok, [], []} ->
        :ok
    end
  end

  def debug() do
    query("select * from cache limit 100")
  end

  defp query(sql, args \\ []) do
    Basic.exec(conn(), sql, args) |> Basic.rows()
  end
end
