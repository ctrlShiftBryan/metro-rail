defmodule MetroRailTest do
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
          {:ok, input, nil,  %Elixir.MetroRailTestStruct{} } |> String.valid?()
      end end.()
    end |> Macro.to_string

    assert input_macro == expected_code
  end
end
