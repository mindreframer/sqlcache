defmodule Sqlcache.Config do
  def rootdir do
    Application.get_env(:sqlcache, :rootdir, ".") |> Path.expand()
  end

  def default_datadir do
    Path.join(rootdir(), "data/sqlcache")
  end
end
