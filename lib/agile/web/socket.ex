defmodule Web.Socket do
  def init(req, _opts) do
    # Start the socket with a timeout of 60 minutes, since people often take long breaks during sprint planning
    {:cowboy_websocket, req, nil, %{ idle_timeout: 60 * 60 * 1000}}
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

  def handle_command(["join", id, user], nil) do
    Registry.register(PointingSession.Dispatcher, id, user)

    PointingSession.join(id, user)

    {:reply, {:text, "ok"}, {id, user}}
  end

  def handle_command(["leave"], {id, user}) do
    PointingSession.leave(id, user)

    Registry.unregister(PointingSession.Dispatcher, id)

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

  # Handle Elixir (non-websocket) messages
  # In the future, this will handle pub-sub info
  def websocket_info({:broadcast, message}, state) do
    # Encode the message as JSON
    # If there's some sort of issue transcoding it, the process will crash
    # This makes sense since you can't reasonably use the pointing session
    # if the data isn't serializable
    {:reply, {:text, Jason.encode!(message)}, state}
  end

  def websocket_info(:shutdown, _) do
    {:reply, {:close, "shutdown"}, nil}
  end

  # If the connection terminates when the user is in a room, remove them
  def terminate(_, _, {id, user}) do
    PointingSession.leave(id, user)
    :ok
  end

  # If they're not in a room, we don't need to do anything
  def terminate(_, _, _) do
    :ok
  end

  defp make_id(bytes) do
      bytes
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64(padding: false)
  end

  # To be extra safe, explicitly describe how Elixir data types
  # should be encoded to JSON
  # In our case, we want to encode structs as maps (which are then encoded as objects)
  # and MapSets as lists (which become arrays)
  defimpl Jason.Encoder, for: [MapSet, Range, Stream] do
    def encode(struct, opts) do
      Jason.Encode.list(Enum.to_list(struct), opts)
    end
  end

  defimpl Jason.Encoder, for: [PointingSession.Core] do
    def encode(struct, opts) do
      Jason.Encode.map(Map.from_struct(struct), opts)
    end
  end
end
