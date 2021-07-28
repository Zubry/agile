defmodule Web.Socket do
  def init(req, _opts) do
    {:cowboy_websocket, req, nil}
  end

  def websocket_init(nil) do
    {:ok, nil}
  end

  def websocket_handle({:text, text}, state) do
    handle_command(String.split(text, ":"), state)
  end

  def handle_command(["start"], _) do
    id = make_id(8)
    PointingSession.start(id)

    {:reply, {:text, id}, nil}
  end

  def handle_command(["join", id, user], _) do
    PointingSession.join(id, user)
    {:reply, {:text, "ok"}, {id, user}}
  end

  def handle_command(["leave"], {id, user}) do
    PointingSession.leave(id, user)
    {:reply, {:text, "ok"}, nil}
  end

  def handle_command(["vote", points], {id, user}) do
    case PointingSession.vote(id, user, points) do
      {:ok, _} -> {:reply, {:text, "ok"}, {id, user}}
      _ -> {:reply, {:text, "error"}, {id, user}}
    end
  end

  def handle_command(["clear_votes"], {id, user}) do
    PointingSession.clear_votes(id)
    {:reply, {:text, "ok"}, {id, user}}
  end

  def handle_command(_, id) do
    {:ok, id, :hibernate}
  end

  defp make_id(bytes) do
      bytes
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64(padding: false)
  end
end
