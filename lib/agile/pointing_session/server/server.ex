defmodule PointingSession.Server do
  use GenServer

  def start_link(id: id) do
    GenServer.start_link(__MODULE__, id, name: {:via, Registry, {PointingSession.Registry, id}})
  end

  def init(id) do
    {:ok, PointingSession.Core.new(id)}
  end

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
    {:reply, pointing_session, pointing_session}
  end

  def handle_call({:leave, user}, _from, pointing_session) do
    pointing_session = PointingSession.Core.leave(pointing_session, user)
    {:reply, pointing_session, pointing_session}
  end

  def handle_call({:vote, user, points}, _from, pointing_session) do
    case PointingSession.Core.vote(pointing_session, user, points) do
      {:ok, pointing_session} -> {:reply, {:ok, pointing_session}, pointing_session}
      {:error, message} -> {:reply, {:error, message}, pointing_session}
    end
  end

  def handle_call({:clear_votes}, _from, pointing_session) do
    pointing_session = PointingSession.Core.clear_votes(pointing_session)
    {:reply, pointing_session, pointing_session}
  end
end
