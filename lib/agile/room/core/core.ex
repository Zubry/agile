defmodule Room.Core do
  alias Room.Core.Users

  defstruct id: nil, users: Users.new()

  def new(id) do
    %__MODULE__{id: id}
  end

  @spec join(map, any) :: map
  def join(room, user) do
    update_in(room.users, fn users -> Users.join(users, user) end)
  end

  def leave(room, user) do
    update_in(room.users, fn users -> Users.leave(users, user) end)
  end
end
