defmodule PointingPoker do
  def new() do
    PointingPoker.Core.new()
  end

  def handle_command({:join, _}, _, room) do
    room
  end

  def handle_command({:leave, user}, _user, room) do
    PointingPoker.Core.leave(room, user)
  end

  def handle_command(["vote", points], user, room) do
    PointingPoker.Core.vote(room, user, points)
  end

  def handle_command(["clear_votes"], _user, room) do
    PointingPoker.Core.clear_votes(room)
  end

  def handle_command(_command, _user, state) do
    {:ok, state}
  end
end
