defmodule PointingSession do
  def start(id) do
    DynamicSupervisor.start_child(
      PointingSession.DynamicSupervisor,
      {PointingSession.Server, id: id}
    )
  end

  def join(id, user) do
    id
    |> lookup()
    |> PointingSession.Server.join(user)
  end

  def leave(id, user) do
    id
    |> lookup()
    |> PointingSession.Server.leave(user)
  end

  def vote(id, user, points) do
    id
    |> lookup()
    |> PointingSession.Server.vote(user, points)
  end

  def clear_votes(id) do
    id
    |> lookup()
    |> PointingSession.Server.clear_votes()
  end

  defp lookup(id) do
    [{pid, _}] = Registry.lookup(PointingSession.Registry, id)
    pid
  end
end
