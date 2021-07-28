defmodule PointingSession.Server do
  use GenServer, restart: :transient

  # After 60 minutes without receiving a message, the server should shut down
  @timeout 1 * 60 * 1000

  def start_link(id: id) do
    GenServer.start_link(__MODULE__, id, name: {:via, Registry, {PointingSession.Registry, id}})
  end

  def init(id) do
    {:ok, PointingSession.Core.new(id), @timeout}
  end

  @spec join(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def join(pid, user) do
    GenServer.call(pid, {:join, user})
  end

  @spec leave(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def leave(pid, user) do
    GenServer.call(pid, {:leave, user})
  end

  def vote(pid, user, points) do
    GenServer.call(pid, {:vote, user, points})
  end

  @spec clear_votes(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def clear_votes(pid) do
    GenServer.call(pid, {:clear_votes})
  end

  def handle_call({:join, user}, _from, pointing_session) do
    pointing_session = PointingSession.Core.join(pointing_session, user)

    dispatch(pointing_session)

    {:reply, pointing_session, pointing_session, @timeout}
  end

  def handle_call({:leave, user}, _from, pointing_session) do
    pointing_session = PointingSession.Core.leave(pointing_session, user)

    dispatch(pointing_session)

    {:reply, pointing_session, pointing_session, @timeout}
  end

  def handle_call({:vote, user, points}, _from, pointing_session) do
    case PointingSession.Core.vote(pointing_session, user, points) do
      {:ok, pointing_session} ->
          dispatch(pointing_session)
          {:reply, {:ok, pointing_session}, pointing_session, @timeout}
      {:error, message} -> {:reply, {:error, message}, pointing_session, @timeout}
    end
  end

  def handle_call({:clear_votes}, _from, pointing_session) do
    pointing_session = PointingSession.Core.clear_votes(pointing_session)

    dispatch(pointing_session)

    {:reply, pointing_session, pointing_session, @timeout}
  end

  def handle_info(:timeout, state) do
    Registry.dispatch(PointingSession.Dispatcher, state.id, fn entries ->
      for {pid, _} <- entries do
        send(pid, :shutdown)
      end
    end)

    {:stop, :normal, state}
  end

  defp dispatch(state) do
    Registry.dispatch(PointingSession.Dispatcher, state.id, fn entries ->
      for {pid, _} <- entries do
        send(pid, {:broadcast, state})
      end
    end)
  end
end
