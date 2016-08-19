defmodule MetroRailIntegrationmTest do
  use ExUnit.Case
  alias MetroRailIntegrationmTest.FooServiceStruct
  defmodule FooServiceStruct do
    defstruct id: 0
  end

  defmodule FooService do
    use MetroRail

    def bar(x) do
      x
      >>> my_query
    end

    def bar_log(x) do
      x
      >>> my_query
      >>> return(:log)
    end

    def my_query(x), do: x
  end

  test "Foo compiles" do
    result = FooService.bar(:ok)
    expected = {:ok, :ok, nil, %FooServiceStruct{id: 0}}
    assert result == expected
  end

  test "Foo logs" do
    result = FooService.bar_log(:ok)
    expected = {:ok, %FooServiceStruct{id: 0}}
    assert result == expected
  end
end
