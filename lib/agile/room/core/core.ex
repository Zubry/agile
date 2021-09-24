defmodule Room.Core do
  alias Room.Core.{Game, Users}

  defstruct id: nil, users: Users.new(), game: nil

  def new(id, game) do
    %__MODULE__{id: id, game: game}
  end

  def valid_game?(game) do
    Game.valid?(game)
  end

  @spec join(map, any) :: map
  def join(room, user) do
    update_in(room.users, fn users -> Users.join(users, user) end)
  end

  def leave(room, user) do
    update_in(room.users, fn users -> Users.leave(users, user) end)
  end

  def forward(command, room) do
    with module when module != nil <- Game.module(room.game) do
      apply(module, :handle_command, [command, room])
    end
  end
end
