defmodule MetroRailIntegrationmTest do
  use ExUnit.Case
  alias MetroRailIntegrationmTest.FooServiceStruct

  defmodule FooServiceStruct do
    defstruct id: 0
  end

  defmodule FooService do
    use MetroRail

    def query(x) do
      x
      >>> my_query
    end

    def cmd(x) do
      x
      >>> (cmd my_cmd)
      |> return
    end

    def bar_log(x) do
      x
      >>> my_query
      >>> return(:log)
    end

    def my_query(x), do: x

    def my_cmd(x, y), do: %FooServiceStruct{ y | id: x }
  end

  test "Foo query" do
    result = FooService.query(:ok)
    expected = {:ok, :ok, nil, %FooServiceStruct{id: 0}}
    assert result == expected
  end

  test "Foo output_in_struct" do
    result = FooService.query(:output_in_struct)
    expected = {:ok, :output_in_struct, nil, %FooServiceStruct{id: 0}}
    assert result == expected
  end

  test "Foo command" do
    result = FooService.cmd(123)
    expected = {:ok, %MetroRailIntegrationmTest.FooServiceStruct{id: 123}}
    assert result == expected
  end

  test "Foo logs" do
    result = FooService.bar_log(:ok)
    expected = {:ok, %FooServiceStruct{id: 0}}
    assert result == expected
  end
end
