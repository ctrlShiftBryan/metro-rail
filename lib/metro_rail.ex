defmodule MetroRail do
  defstruct id: "This is just here for unit tests."

  @moduledoc File.read!("README.md")
  require IEx

  defmacro __using__(_) do
    quote do
      import MetroRail



      @doc ~S"""
        Returns the struct
      """
      def my_struct do
        unquote(struct_ast(__CALLER__.module))
      end

      @doc ~S"""
       Strips the input and callstack from the 4 value tuple.
      """
      def return({status, _, _, output}) do
        {status, output}
      end

      def return({status, _, callstack, output} = last, :log) do
        stack_status = get_status(last)
         MetroRail.Logging.log_stack(stack_status, last)
        {status, output}
      end

      @doc """
        If there is anythign in the stack other than :ok the first thing encountered in reverse order will be returned as the status of the entire stack.
      """
      defp get_status({:ok, _, nil, _}), do: :ok
      defp get_status({:ok, _, callstack, _}), do: get_status(callstack)
      defp get_status({status, input, callstack, struct}), do: status

    end
  end


  @doc ~S"""
     Will return the name of the struct for this MetroRail

     For example if this macro is used in 'RequestService' it will return 'RequestServiceStruct'
  """
  def struct_ast(x) do
    {:%, [],
     [{:__aliases__, [alias: false],
      [(x |> Atom.to_string)
      <> "Struct" |> String.to_atom]}, {:%{}, [], []}]}
  end

  @doc ~S"""
    Given a 4 value Metro Tuple where the 4th tuple is the services struct it will pass it along

    Otherwise it will create the 4 value Metro Tuple and use the entire input as the 2nd value
  """
  defmacro left >>> right do
    quote do
      (fn ->
        case unquote(left) do
          { status, input, call_stack, context_struct} ->
            unquote(left)
            |> unquote(right)

          input ->
            {:ok, input, nil, unquote(struct_ast(__CALLER__.module))}
            |> unquote(right)
        end
      end).()
    end
  end

  #TODO use bind_quoted if possible. it doesn't work for some reason maybe because we are using the special operator
  # defmacro left ~>> right do
  #   quote bind_quoted: [left: left, right: right, struct: struct_ast(__CALLER__.module)] do
  #     (fn ->
  #       case left do
  #         { status, input, call_stack, context_struct} ->
  #           left
  #           |> right
  #
  #         input ->
  #           {:ok, input, nil, struct }
  #           |> right
  #       end
  #     end).()
  #   end
  # end
end
