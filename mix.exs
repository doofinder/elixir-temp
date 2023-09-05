defmodule Temp.Mixfile do
  use Mix.Project

  @source_url "https://github.com/doofinder/elixir-temp"
  @version "0.4.7"

  def project do
    [
      app: :temp,
      version: @version,
      elixir: "~> 1.12",
      aliases: aliases(),
      name: "temp",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      description: description(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [source_ref: "#{@version}", extras: ["README.md"], main: "readme"]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "An Elixir module to easily create and use temporary files and directories."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Daniel Perez"],
      licenses: ["MIT"],
      organization: "doofinder",
      links: %{"GitHub" => @source_url}
    ]
  end

  defp aliases do
    [
      test: [
        "test --no-start"
      ],
      consistency: [
        "format",
        "compile --force --warnings-as-errors --no-deps-check",
        "credo --strict --ignore todo",
        "dialyzer"
      ]
    ]
  end
end
