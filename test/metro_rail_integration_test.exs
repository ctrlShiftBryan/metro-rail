defmodule MetroRailIntegrationmTest do
  use ExUnit.Case
  alias MetroRailIntegrationmTest.FooServiceStruct
  require IEx
  import ExUnit.CaptureLog

  defmodule FooServiceStruct do
    defstruct id: 0
  end
  defmodule Get do
    def val("one"), do: 1
  end
  defmodule Get.Longer do
    def val(_), do: 1
  end
  defmodule FooService do
    use MetroRail
    alias Get.Longer, as: G
    def query(x) do
      x
      >>> my_query
    end

    def cmd(x) do
        x
        >>> (cmd my_cmd)
        |> return
    end

    def query_logs(x) do
      x
      >>> (query times_two)
      >>> (query times_two)
      >>> (query times_two)
      >>> (query times_two)
      >>> (query times_two)
      >>> return(:log)
    end

    def query_error(x) do
      x
      >>> (query times_two)
      >>> (query times_two)
      >>> (query times_two_error)
      >>> (query times_two)
      >>> (query times_two)
      |> return
    end

    def query_log do
      1
      >>> (query times_two)
      # >>> (query times_two)
      |> return(:log)
    end

    def query_error_log(x) do
      x
      >>> (query times_two)
      >>> (query times_two)
      >>> (query times_two_error)
      >>> (query times_two)
      >>> (query times_two)
      |> return(:log)
    end

    def non_status_tuple do
      {:not_error, 42}
      >>> (query my_query)
      |> return
    end

    def my_query(x), do: x
    def times_two(x), do: x * 2
    def times_two_error(x), do: {:error, ""}
    def my_cmd(x, y), do: %FooServiceStruct{ y | id: x }
  end

  test "Two value tuple not :ok or :error doesnt get treated as error" do
    result = FooService.non_status_tuple()
    expected = {:ok, %FooServiceStruct{id: 0}}
    assert result == expected
  end

  test "Foo query" do
    result = FooService.query(:ok)
    {status, i, stack, struct} = result
    expected = {status, :ok, nil, %FooServiceStruct{id: 0}}
    assert result == expected
  end

  test "Error stops calls" do
    result = FooService.query_error(1)
    expected = {:error, %MetroRailIntegrationmTest.FooServiceStruct{id: 0}}
    assert result == expected
  end

  test "Foo output_in_struct" do
    result = FooService.query(:output_in_struct)
    {status, i, stack, struct} = result
    expected = {status, :output_in_struct, nil, %FooServiceStruct{id: 0}}
    assert result == expected
  end

  test "Foo command" do
    result = FooService.cmd(123)
    expected = {:ok, %MetroRailIntegrationmTest.FooServiceStruct{id: 123}}
    assert result == expected
  end

  test "Foo logs" do
    log = capture_log(log_options, fn ->
      result = FooService.query_logs(1)
      expected = {:ok, %FooServiceStruct{id: 0}}
      assert result == expected
    end) |> log_to_list()

    expected_log =
         [
           ~r|\[debug\] {:ok, (.)+ Input: 1 Output: 2|,
           ~r|\[debug\] {:ok, (.)+ Input: 2 Output: 4|,
           ~r|\[debug\] {:ok, (.)+ Input: 4 Output: 8|,
           ~r|\[debug\] {:ok, (.)+ Input: 8 Output: 16|,
           ~r|\[debug\] {:ok, (.)+ Input: 16 Output: 32|
         ]

    assert_log(log, expected_log)
  end

  @tag :wip
  test "Foo logs with meta" do
    log = capture_log(log_options, fn ->
      result = FooService.query_log
      expected = {:ok, %FooServiceStruct{id: 0}}
      assert result == expected
    end) |> log_to_list()

    expected_log =
      [~r|\[debug\] {:ok, (.)+ Input: 1 Output: 2|]

    assert_log(log, expected_log)
  end

  def assert_log(actual, expected) do
    zipped = Enum.zip(actual, expected)
    for {actual_log, expected_log} <- zipped, do: assert actual_log =~ expected_log
  end

  test "Foo logs error" do
    log = capture_log(log_options, fn ->
      result = FooService.query_error_log(1)
    end) |> log_to_list()

    expected_log =
      [
        ~r|\[error\] {:ok, (.)+ Input: 1 Output: 2|,
        ~r|\[error\] {:ok, (.)+ Input: 2 Output: 4|,
        ~r|\[error\] {:error, (.)+ Input: 4 Output: {:error, \"\"}|
      ]

    assert_log(log, expected_log)
  end

  defp log_options do
    [ format: "|*log*| $metadata[$level] $message" ]
  end

  defp log_to_list(log) do
    log
    |> String.split(~r(\e\[[0-9]+m\|\*log\*\|[ ]))
    |> Enum.filter_map(fn(x) -> x != "" end,   fn(x) -> String.replace(x, "\e[0m","")  end)
  end
end
