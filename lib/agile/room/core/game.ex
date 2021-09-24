defmodule Room.Core.Game do
  @games Application.fetch_env!(:agile, :games)

  def valid?(game) do
    Enum.member?(@games, game)
  end
end
