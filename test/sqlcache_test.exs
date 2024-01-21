defmodule SqlcacheTest do
  use ExUnit.Case
  doctest Sqlcache

  describe "basic run" do
    test "works" do
      assert :ok == Sqlcache.clear_namespace("test")
      assert :ok == Sqlcache.put("test", "a", 1)
      assert {:ok, 1} == Sqlcache.get("test", "a")
      assert :ok == Sqlcache.put("test", "a", %{a: 1, b: 2})
      assert {:ok, %{a: 1, b: 2}} == Sqlcache.get("test", "a")
      assert :ok == Sqlcache.clear_namespace("test")
      assert {:error, nil} == Sqlcache.get("test", "a")
    end

    test "sql queries work" do
      assert :ok == Sqlcache.clear_namespace("test")
      assert :ok == Sqlcache.put("test", "a", 1)

      assert Sqlcache.query("select ns, key, value from cache where ns = 'test'") == {
               :ok,
               [
                 %{
                   "key" => "a",
                   "ns" => "test",
                   "value" => <<120, 156, 107, 78, 100, 4, 0, 2, 79, 0, 230>>
                 }
               ]
             }
    end
  end
end
