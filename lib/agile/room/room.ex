defmodule Room do
  def start(id) do
    DynamicSupervisor.start_child(
      Room.DynamicSupervisor,
      {Room.Server, id: id}
    )
  end

  def join(id, user) do
    id
    |> lookup()
    |> Room.Server.join(user)
  end

  def leave(id, user) do
    id
    |> lookup()
    |> Room.Server.leave(user)
  end

  defp lookup(id) do
    [{pid, _}] = Registry.lookup(Room.Registry, id)
    pid
  end
end
