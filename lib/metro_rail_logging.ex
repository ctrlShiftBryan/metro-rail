defmodule MetroRail.Logging do
    require Logger
    require IEx

    def log_stack(stack_status, {_, _, callstack, _} = stack) do
      log_stack(stack_status, callstack)
      log_both(stack_status, callstack, stack)
    end
    def log_stack(stack_status, stack) do
      log_both(stack_status, stack, stack)
    end

    def log_both(t, {s, i, _, _}, {_, nil, _, o}), do: call_logger(t, s, i, o)
    def log_both(t, {s, i, _, _}, {_, o, _, _}), do: call_logger(t, s, i, o)
    def log_both(t, {s, i, _, o}, _), do: call_logger(t, s, i, o)
    def log_both(t, nil, _) do
    end

    defp call_logger(overall, status, input, output) do
      case overall do
         :ok -> Logger.debug format_log(input, output, status)
         :error -> Logger.error format_log(input, output, status)
         _ -> Logger.warn format_log(input, output, status)
      end
    end
    defp format_log(input, output, status) do
      "#{inspect status} Input: #{inspect input} Output: #{inspect output}"
    end
end
