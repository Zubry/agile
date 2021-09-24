defmodule Agile.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Agile.Worker.start_link(arg)
      # {Agile.Worker, arg}
      {Registry, keys: :unique, name: Room.Registry},
      {DynamicSupervisor, name: Room.DynamicSupervisor, strategy: :one_for_one},
      {Registry, keys: :duplicate, name: Room.Dispatcher},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Web.Router,
        options: [port: Application.fetch_env!(:agile, :port), dispatch: dispatch()]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Agile.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", Web.Socket, []},
         {:_, Plug.Cowboy.Handler, {Web.Router, []}}
       ]}
    ]
  end
end
