defmodule TaskBunnyAppsignal.MixProject do
  use Mix.Project

  def project do
    [
      app: :task_bunny_appsignal,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:appsignal, "~> 1.0"},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:jason, "~> 1.1"},
      {:mimic, "~> 1.0", only: :test},
      {:task_bunny, github: "savisolutions/task_bunny"}
    ]
  end
end
