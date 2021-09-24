defmodule PointingPoker do
  def handle_command(command, state) do
    IO.inspect({command, state})
    state
  end
end
