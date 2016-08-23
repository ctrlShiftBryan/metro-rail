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

          { :ok, input, call_stack, context_struct} ->
            unquote(left)
            |> unquote(right)

          { status, input, call_stack, context_struct} = not_ok ->
            not_ok

          input ->
            {:ok, input, nil, unquote(struct_ast(__CALLER__.module))}
            |> unquote(right)
        end
      end).()
    end
  end

  @doc ~S"""
    Turns a function call AST into an anonymous function call AST with specific arity

    For example 'print' becomes '&print\2'
  """
  def func_to_anon({func, meta, args}, arity) do
    {:&, [], [{:/, [context: Elixir, import: Kernel], [{func, meta, args}, arity]}]}
  end

  @doc ~S"""
    Will call a function using a single input in position b of a 4 value tuple.

    The returned 4 value tuple will be {a, b, c, d}

    a - if a tuple is returned by a function call it will be the first value in that tuple
        if no tuple is returned it will simply pass along a

    b - the output of the function call

    c - the entire input

    d - d will be passed along unmodified

  """
  defmacro query(args, func) do
    quote do
      e = unquote(args)
      {a, b, c, d} = e

      #if b is nil use struct as input
      input = case b do
        :output_in_struct -> d
        _ -> b
      end

      results = input |> unquote(func)
      case results do
        {status, value} -> {status, results, e, d}
        value -> {a, results, e, d}
      end
    end
  end

  @doc ~S"""
    Will call a function using two specific values from the 4 value tuple.

    Given a four value tuple {a, b, c, d} the function will be called with the inputs 'a' and 'd'

    The returned 4 value tuple will be
    a - if a tuple is returned by a function call it will be the first value in that tuple
        if no tuple is returned it will simply pass along a

    b - this will always be :output_in_struct indicating the struct was updated

    c - this is the entire input of the function call

    d - this is the new value returned by the function call
  """
  defmacro cmd(args, func) do
    new_ast = func_to_anon(func, 2)
    quote do
      fun = unquote(new_ast)
      e = unquote(args)
      {a, b, c, d} = e
      results = b |> fun.(d)
      case results do
        {status, value} -> {status, :output_in_struct, e, value}
        value -> {a, :output_in_struct, e, value}
      end
    end
  end
  # TODO use bind_quoted if possible. it doesn't work for some reason maybe because we are using the special operator
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
