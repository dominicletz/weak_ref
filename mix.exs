defmodule WeakRef.MixProject do
  use Mix.Project

  @version "1.0.0"
  @name "WeakRef"
  @url "https://github.com/dominicletz/weak_ref"
  @maintainers ["Dominic Letz"]

  def project do
    [
      app: :weak_ref,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: @name,
      compilers: [:weak_ref] ++ Mix.compilers(),
      docs: docs(),
      package: package(),
      homepage_url: @url,
      description: """
      Weak references for Elixir.
      For Linux, MacOS, Windows (msys2)
      """
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: @name,
      source_ref: "v#{@version}",
      source_url: @url,
      authors: @maintainers
    ]
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{github: @url},
      files:
        ~w(c_src src lib priv) ++
          ~w(CHANGELOG.md LICENSE.md mix.exs README.md)
    ]
  end
end

defmodule Mix.Tasks.Compile.WeakRef do
  use Mix.Task
  @moduledoc false

  def run(args) do
    Mix.shell().info("Compiling nif with args: #{inspect(args)}")

    case System.cmd("make", ["-C", "c_src"]) do
      {_, 0} -> :ok
      {error, code} -> {:error, ["Failed to compile NIF: #{inspect({code})}", error]}
    end
  end
end
