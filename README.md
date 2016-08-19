# MetroRail

Metro Rail is a set of macros for building 'services' that aggregate a bunch of function calls using railway like pipes.

## Concepts
There are a few key concepts to understand. Essentially you will be building a 'service' function that builds up a struct by making several function calls. Functions along the rail can be optionally skipped if any of the previous calls failed. A context in the form of a Struct is passed along the rail. The entire call stack of all functions called is also saved.

### The Metro Tuple
The key to Metro Rail is the 'Metro Tuple'.
```elixir
{ status, input_output, call_stack, context_struct}
```
This tuple is both the input and the output of all functions calls along the metro rail.

### The Pipe replacement
The ```>>>``` operator used in place of the normal `|>` operator.
This is what allows functions to be ignorant of the Metro Tuple.

Instead of this
```elixir
  {:ok, 1245, nil, %ContextStruct{}}
  |> get_user
```
The `get_user` function must be written to return the Metro Tuple

We can write this.
```elixir
  1245  
  >>> (query get_user)
```
The `get_user` function can be written ignorant of the Metro Tuple as long as it takes a single input. We mark the get_user as a query type function so that MetroRail knows how to transform inputs and outputs. It also helps the developer visualize which of the types of the functions is being called.

### The Context Struct
The 'service' function will be working to build up a Struct which you define. This struct is passed to all functions along the rail. The struct will need to follow the naming convention of module name + "Struct". For example if the `use MetroRail` is included in the `ShoppingCart` module the struct will be named `ShoppingCartStruct`
```elixir
   def ShoppingCartStruct do
     defstruct id: 0, status: :ok, total: 0, items: []
   end
```
### Works with two types of functions
There are two types of functions you can put in the rail.

#### Query Functions (1 input, any out put)
The query function is a 1 arity function that takes a single input and returns arbitrary output. These functions should be written without any knowledge of MetroRail. They are often things like calls to HTTPPoison or other external libraries. They do not mutate the context.
```elixir
   def calculate_tax(total) do
      total * 0.7  
   end
```

#### Command Functions (2 inputs, context output)
The command function is a 2 arity function that takes arbitrary input and the Context Struct and returns the Context Struct. These DO mutate the context.
```elixir
   def add_to_cart(item, cart) do
      %ShoppingCartStruct{ cart | items: [ item | cart.items ]}
   end
```

## Non Railway Function Piping
One of the main goals of the package is to allow you to create your functions without having to write them in any special way but still have them be processed by the railway. However, you can also always create a MetroRail aware function that takes the Metro Tuple as inputs and outputs and used the normal `|>` operator.

## Return function and logging
The return function unwraps the 4 value tuple and turns it back into
```elixir
   {:ok, context_struct}
```

```return``` also has a :log option that will log the entire stack under the appropriate logger call.

```elixir
   >>> return(:log)
```
Debug - If all calls in the stack have a status of ok.

Error - If a single call in the stack has a status of error.

Warning - If a single call in the stack has some other status and there is no error.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `metro_rail` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:metro_rail, "~> 0.1.0"}]
    end
    ```

  2. Ensure `metro_rail` is started before your application:

    ```elixir
    def application do
      [applications: [:metro_rail]]
    end
    ```
