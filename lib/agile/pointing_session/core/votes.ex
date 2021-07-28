defmodule PointingSession.Core.Votes do
  def new do
    %{}
  end

  def vote(votes, user, vote) do
    Map.put(votes, user, vote)
  end

  def remove_vote(votes, user) do
    Map.delete(votes, user)
  end
end
