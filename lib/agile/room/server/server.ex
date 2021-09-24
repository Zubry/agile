defmodule Room.Server do
  use GenServer, restart: :transient

  # After 60 minutes without receiving a message, the server should shut down
  @timeout 60 * 60 * 1000

  def start_link(id: id, game: game) do
    GenServer.start_link(__MODULE__, {id, game}, name: {:via, Registry, {Room.Registry, id}})
  end

  def init({id, game}) do
    {:ok, Room.Core.new(id, game), @timeout}
  end

  @spec join(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def join(pid, user) do
    GenServer.call(pid, {:join, user})
  end

  @spec leave(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def leave(pid, user) do
    GenServer.call(pid, {:leave, user})
  end

  def handle_call({:join, user}, _from, room) do
    room = Room.Core.join(room, user)

    dispatch(room)

    {:reply, room, room, @timeout}
  end

  def handle_call({:leave, user}, _from, room) do
    room = Room.Core.leave(room, user)

    dispatch(room)

    {:reply, room, room, @timeout}
  end

  def handle_info(:timeout, state) do
    Registry.dispatch(Room.Dispatcher, state.id, fn entries ->
      for {pid, _} <- entries do
        send(pid, :shutdown)
      end
    end)

    {:stop, :normal, state}
  end

  defp dispatch(state) do
    Registry.dispatch(Room.Dispatcher, state.id, fn entries ->
      for {pid, _} <- entries do
        send(pid, {:broadcast, state})
      end
    end)
  end
end
