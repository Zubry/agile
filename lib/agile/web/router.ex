defmodule Web.Router do
  use Plug.Router

  # Apply logging middleware
  plug(Plug.Logger)

  # Adds "match" functions to this piece of plug middleware
  plug(:match)

  # Executes matched code (from the match plug)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end
end
