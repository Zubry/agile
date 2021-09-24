defmodule Room.Core.Game do
  @games Application.fetch_env!(:agile, :games)

  def valid?(game) do
    @games
    |> Enum.map(fn {_, name} -> name end)
    |> Enum.member?(game)
  end

  def module(game) do
    @games
    |> Enum.filter(fn {_, name} -> name == game end)
    |> Enum.map(fn {module, _} -> module end)
    |> List.first()
  end
end
