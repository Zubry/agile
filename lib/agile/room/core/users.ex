defmodule Room.Core.Users do
  def new() do
    MapSet.new()
  end

  def join(users, user) do
    MapSet.put(users, user)
  end

  def leave(users, user) do
    MapSet.delete(users, user)
  end

  def member?(users, user) do
    MapSet.member?(users, user)
  end
end
