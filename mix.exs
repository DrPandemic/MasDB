defmodule Masdb.Mixfile do
  use Mix.Project

  def project do
    [app: :masdb,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
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
     {:power_assert, "~> 0.0.8", only: :test}
    ]
  end
end
