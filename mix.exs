defmodule MetroRail.Mixfile do
  use Mix.Project

  def project do
    [app: :metro_rail,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:mock, "~> 0.1.1", only: :test}]
  end

  defp description do
    """
    Metro Rail is a set of macros for building 'services' that aggregate a bunch of function calls using railway like pipes.
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :metro_rail,
     files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Bryan Arendt"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/ctrlShiftBryan/metro-rail"}]
  end
end
