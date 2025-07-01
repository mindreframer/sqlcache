defmodule Sqlcache.WrapperTest do
  use ExUnit.Case

  defmodule Dummy do
    use Sqlcache.Wrapper, namespace: "dummy"

    defcached get_value(x) do
      {:ok, x * 2}
    end

    defcached get_error(x) do
      {:error, :fail}
    end

    def remove_from_cache(x) do
      del(:get_value, [x])
    end
  end

  defmodule DummyWithCounter do
    use Sqlcache.Wrapper, namespace: "dummy_counter"

    def counter, do: :persistent_term.get(:dummy_counter, 0)
    def reset_counter, do: :persistent_term.put(:dummy_counter, 0)

    defcached get_value(x) do
      :persistent_term.put(:dummy_counter, counter() + 1)
      {:ok, x * 10}
    end

    defcached get_error(x) do
      {:error, :fail}
    end

    def remove_from_cache(x) do
      del(:get_value, [x])
    end
  end

  setup do
    Sqlcache.clear_namespace("dummy")
    :ok
  end

  test "caches and returns value" do
    assert {:ok, 4} = Dummy.get_value(2)
    # Should be cached now
    assert {:ok, 4} = Dummy.get_value(2)
  end

  test "removes value from cache" do
    assert {:ok, 6} = Dummy.get_value(3)
    Dummy.remove_from_cache(3)
    # Should recompute after deletion
    assert {:ok, 6} = Dummy.get_value(3)
  end

  test "does not cache error tuples" do
    assert {:error, :fail} = Dummy.get_error(1)
    # Should call function again, not cache
    assert {:error, :fail} = Dummy.get_error(1)
  end

  test "key/2 is deterministic" do
    k1 = Sqlcache.Wrapper.key(:foo, [1, 2])
    k2 = Sqlcache.Wrapper.key(:foo, [1, 2])
    refute Sqlcache.Wrapper.key(:foo, [2, 1]) == k1
    assert k1 == k2
  end

  describe "caching behavior" do
    setup do
      DummyWithCounter.reset_counter()
      Sqlcache.clear_namespace("dummy_counter")
      :ok
    end

    test "function body is not executed if value is cached" do
      assert DummyWithCounter.counter() == 0
      assert {:ok, 20} = DummyWithCounter.get_value(2)
      assert DummyWithCounter.counter() == 1
      # Call again, should hit cache, not increment counter
      assert {:ok, 20} = DummyWithCounter.get_value(2)
      assert DummyWithCounter.counter() == 1
    end
  end
end
