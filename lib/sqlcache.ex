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
      "create table if not exists cache (ns string, key string, value string, ts string, PRIMARY KEY ( ns, key))",
      "create index if not exists cache_ns_idx on cache(ns);"
    ]
    |> Enum.each(fn stmt -> :ok = Exqlite.Sqlite3.execute(conn.db, stmt) end)
  end

  def conn do
    :persistent_term.get(:cache_conn)
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def put(ns, key, value) do
    value = Compressor.compress(value)
    ts = DateTime.utc_now() |> DateTime.to_unix(:microsecond)

    case query("insert or replace into cache(ns, key, value, ts) values (?, ?, ?, ?)", [
           ns,
           key,
           value,
           ts
         ]) do
      {:ok, []} -> :ok
    end
  end

  def get(ns, key) do
    case query("select value from cache where ns =  ? and key = ?", [ns, key]) do
      {:ok, []} -> {:error, nil}
      {:ok, [%{"value" => val}]} -> {:ok, Compressor.uncompress(val)}
    end
  end

  def del(ns, key) do
    case query("delete from cache where ns =  ? and key = ?", [ns, key]) do
      {:ok, []} -> :ok
    end
  end

  def clear_kind(ns), do: clear_namespace(ns)

  def clear_namespace(ns) do
    case query("delete from cache where ns = ?", [ns]) do
      {:ok, []} ->
        :ok
    end
  end

  def debug() do
    query("select * from cache limit 100")
  end

  def query(sql, args \\ []) do
    res = Basic.exec(conn(), sql, args) |> Basic.rows()

    case res do
      {:ok, columns, rows} -> {:ok, as_maps(columns, rows)}
    end
  end

  defp as_maps(rows, columns) do
    rows
    |> Enum.map(fn row ->
      Enum.zip(columns, row) |> Enum.into(%{})
    end)
  end
end
