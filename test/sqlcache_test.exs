defmodule SqlcacheTest do
  use ExUnit.Case
  doctest Sqlcache

  describe "basic run" do
    test "works" do
      assert :ok == Sqlcache.clear_kind("test")
      assert :ok == Sqlcache.put("test", "a", 1)
      assert {:ok, 1} == Sqlcache.get("test", "a")
      assert :ok == Sqlcache.put("test", "a", %{a: 1, b: 2})
      assert {:ok, %{a: 1, b: 2}} == Sqlcache.get("test", "a")
      assert :ok == Sqlcache.clear_kind("test")
      assert {:error, nil} == Sqlcache.get("test", "a")
    end

    test "sql queries work" do
      assert :ok == Sqlcache.clear_kind("test")
      assert :ok == Sqlcache.put("test", "a", 1)

      assert Sqlcache.query("select key, kind, value from cache where kind = 'test'") == {
               :ok,
               [
                 %{
                   "key" => "a",
                   "kind" => "test",
                   "value" => <<120, 156, 107, 78, 100, 4, 0, 2, 79, 0, 230>>
                 }
               ]
             }
    end
  end
end
