defmodule PointingSession.Core do
  alias PointingSession.Core.{Users, Votes}

  defstruct id: nil, users: Users.new(), votes: Votes.new()

  def new(id) do
    %__MODULE__{id: id}
  end

  @spec join(map, any) :: map
  def join(pointing_session, user) do
    update_in(pointing_session.users, fn users -> Users.join(users, user) end)
  end

  def leave(pointing_session, user) do
    pointing_session = update_in(pointing_session.users, fn users -> Users.leave(users, user) end)
    update_in(pointing_session.votes, fn votes -> Votes.remove_vote(votes, user) end)
  end

  def vote(pointing_session, user, points) do
    if Users.member?(pointing_session.users, user) do
      {:ok,
       update_in(pointing_session.votes, fn votes ->
         Votes.vote(votes, user, points)
       end)}
    else
      {:error, "Not in pointing session"}
    end
  end

  def clear_votes(pointing_session) do
    put_in(pointing_session.votes, Votes.new())
  end
end
