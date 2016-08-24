defmodule MetroRail.Logging do
    require Logger

    def log_stack(stack_status, {_, _, callstack, _} = stack) do
      log_stack(stack_status, callstack)
      log_both(stack_status, callstack, stack)
    end
    def log_stack(stack_status, stack) do
      log_both(stack_status, stack, stack)
    end

    def log_both(t, {_, i, _, _}, {s, nil, _, o}), do: call_logger(t, s, i, o)
    def log_both(t, {_, i, _, _}, {s, o, _, _}), do: call_logger(t, s, i, o)
    def log_both(t, {_, i, _, o}, {s, _, _, _}), do: call_logger(t, s, i, o)
    def log_both(t, nil, _) do
    end

    defp call_logger(overall, status, input, output) do
      case overall do
         {:ok, _} -> Logger.debug format_log(input, output, status)
         {:error, _} -> Logger.error format_log(input, output, status)
         :ok -> Logger.debug format_log(input, output, status)
         :error -> Logger.error format_log(input, output, status)
         _ -> Logger.warn format_log(input, output, status)
      end
    end
    defp format_log(input, output, status) do
      "#{inspect status} Input: #{inspect input} Output: #{inspect output}"
    end
end
