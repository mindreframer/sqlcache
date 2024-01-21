defmodule Sqlcache.MixProject do
  use Mix.Project
  @github_url "https://github.com/mindreframer/sqlcache"
  @version "1.0.0"
  @description "Sqlite based key/value cache with namespacing."

  def project do
    [
      app: :sqlcache,
      source_url: @github_url,
      version: @version,
      description: @description,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Sqlcache.Application, []}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README* CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "Github" => @github_url,
        "Changelog" => "#{@github_url}/blob/main/CHANGELOG.md"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exqlite, "~> 0.19"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end
end
