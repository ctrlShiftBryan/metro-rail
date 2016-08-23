defmodule MetroRailUnitTest do
  use ExUnit.Case
  doctest MetroRail
  require MetroRail

  test "ensure loaded" do
    assert Code.ensure_loaded?(MetroRail)
  end

  test ">>> expands properly" do
    input_macro = quote do
      MetroRail.>>>(:x, String.valid?)
    end |> Macro.expand( __ENV__ ) |> Macro.to_string

    expected_code = quote do
      fn -> case(:x) do
        {status, input, call_stack, context_struct} ->
          :x |> String.valid?()
        input ->
          {:ok, input, nil, %Elixir.MetroRailUnitTestStruct{} } |> String.valid?()
      end end.()
    end |> Macro.to_string

    assert input_macro == expected_code
  end

  test "query expands properly" do
    input_macro = quote do
      MetroRail.query(:x, String.valid?)
    end |> Macro.expand( __ENV__ ) |> Macro.to_string

    expected_code = quote do
    (
      e = :x
      {a, b, c, d} = e
      input = case(b) do
            :output_in_struct -> d
            _ -> b
          end
      results = input |> String.valid?()
      case(results) do
        {status, value} ->
          {status, results, e, d}
        value ->
          {a, results, e, d}
      end
    )
    end |> Macro.to_string

    assert input_macro == expected_code
  end

  test "query expands properly arity 2" do
    input_macro = quote do
      MetroRail.query("a abc a", String.trim("a"))
    end |> Macro.expand( __ENV__ ) |> Macro.to_string

    expected_code = quote do
    (
      e = :x
      {a, b, c, d} = e
      input = case(b) do
            :output_in_struct -> d
            _ -> b
          end
      results = input |> String.trim("a")
      case(results) do
        {status, value} ->
          {status, results, e, d}
        value ->
          {a, results, e, d}
      end
    )
    end |> Macro.to_string
  end


  test "cmd expands properly" do
    input_macro = quote do
      MetroRail.cmd(:x, String.valid?)
    end |> Macro.expand( __ENV__ ) |> Macro.to_string

    expected_code = quote do
    (
      fun = &String.valid?/2
      e = :x
      {a, b, c, d} = e
      results = b |> fun.(d)
      case(results) do
      {status, value} ->
      {status, :output_in_struct, e, value}
      value ->
          {a, :output_in_struct, e, value}
      end
    )
    end |> Macro.to_string

    assert input_macro == expected_code
  end
end
