defmodule PointingPoker.Core do
  alias PointingPoker.Core.Votes

  defstruct votes: Votes.new(), revealed: false

  def new() do
    %__MODULE__{}
  end

  def leave(room, user) do
    update_in(room.state.votes, fn votes -> Votes.remove_vote(votes, user) end)
  end

  def vote(room, user, points) do
    if Room.Core.Users.member?(room.users, user) do
      {:ok,
       update_in(room.state.votes, fn votes ->
         Votes.vote(votes, user, points)
       end)}
    else
      {:error, "Not in pointing session"}
    end
  end

  def clear_votes(room) do
    room = put_in(room.state.votes, Votes.new())
    room = put_in(room.state.revealed, false)
    {:ok, room}
  end

  def reveal_votes(room) do
    {:ok, put_in(room.state.revealed, true)}
  end

  def unreveal_votes(room) do
    {:ok, put_in(room.state.revealed, false)}
  end
end
