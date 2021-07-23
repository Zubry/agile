defmodule PointingSession.Core.Votes do
  def new do
    %{}
  end

  def vote(votes, user, vote) do
    Map.put(votes, user, vote)
  end
end
