defmodule Web.Socket do
  def init(req, _opts) do
    # Start the socket with a timeout of 60 minutes, since people often take long breaks during sprint planning
    {:cowboy_websocket, req, nil, %{idle_timeout: 60 * 60 * 1000}}
  end

  def websocket_init(nil) do
    {:ok, nil}
  end

  def websocket_handle({:text, text}, state) do
    with [id | command] <- String.split(text, ":"),
         {response, state} <- handle_command(command, state) do
      {:reply, {:text, id <> ":" <> response}, state}
    else
      nil -> {:ok, state, :hibernate}
    end
  end

  def handle_command(["start", game], _) do
    id = make_id(8)

    case Room.start(id, game) do
      {:error, _} ->
        {"error", nil}

      _ ->
        {id, nil}
    end
  end

  def handle_command(["join", id, user], nil) do
    Registry.register(Room.Dispatcher, id, user)

    Room.join(id, user)

    {"ok", {id, user}}
  end

  def handle_command(["leave"], {id, user}) do
    Room.leave(id, user)

    Registry.unregister(Room.Dispatcher, id)

    {"ok", nil}
  end

  # def handle_command(["vote", points], {id, user}) do
  #   case PointingSession.vote(id, user, points) do
  #     {:ok, _} -> {"ok", {id, user}}
  #     _ -> {"error", {id, user}}
  #   end
  # end

  # def handle_command(["clear_votes"], {id, user}) do
  #   PointingSession.clear_votes(id)
  #   {"ok", {id, user}}
  # end

  def handle_command(command, {id, user}) do
    case Room.forward(id, user, command) do
      {:ok, _} -> {"ok", {id, user}}
      {:error, message} -> {message, {id, user}}
      _ -> {"ok", {id, user}}
    end
  end

  def handle_command(_, _) do
    nil
  end

  # Handle Elixir (non-websocket) messages
  # In the future, this will handle pub-sub info
  def websocket_info({:broadcast, message}, state) do
    # Encode the message as JSON
    # If there's some sort of issue transcoding it, the process will crash
    # This makes sense since you can't reasonably use the pointing session
    # if the data isn't serializable
    {:reply, {:text, "update:" <> Jason.encode!(message)}, state}
  end

  def websocket_info(:shutdown, _) do
    {:reply, {:close, "shutdown"}, nil}
  end

  # If the connection terminates when the user is in a room, remove them
  def terminate(_, _, {id, user}) do
    Room.leave(id, user)
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

  defimpl Jason.Encoder, for: [Room.Core, PointingPoker.Core] do
    def encode(struct, opts) do
      Jason.Encode.map(Map.from_struct(struct), opts)
    end
  end
end
