defmodule Masdb.Mixfile do
  use Mix.Project

  def project do
    [app: :masdb,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     dialyzer: [flags: [
                   :error_handling,
                   :race_conditions,
                   :underspecs,
                   :no_unused,
                   :unknown,
                 ]],
    ]
  end

  def application do
    [
      mod: {Masdb.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
     {:distillery, "~> 1.0"},
     {:power_assert, "~> 0.0.8", only: :test},
     {:credo, "== 0.6.1", only: [:dev, :test], runtime: false},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
    ]
  end
end
