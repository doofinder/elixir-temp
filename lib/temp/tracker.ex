defmodule Temp.Tracker do
  @moduledoc """
  This module manages the state and it's also in charge of the automatic resource cleanup when the process that called Temp.track/0 terminates

  The state contains all the files that a process has generated (if they are been tracked!) and it follows the schema:
  [
    {file_path::Path.t(), file_decriptor::File.io_device()| nil}
  ]
  """
  use GenServer

  if :elixir
     |> :application.get_key(:vsn)
     |> elem(1)
     |> to_string()
     |> Version.match?("~> 1.1") do
    defp set, do: MapSet.new()
    defdelegate put(set, value), to: MapSet
  else
    defp set, do: HashSet.new()
    defdelegate put(set, value), to: HashSet
  end

  @impl GenServer
  def init(_args) do
    Process.flag(:trap_exit, true)
    {:ok, set()}
  end

  @impl GenServer
  def handle_call({:add, file_path, fd}, _from, state) do
    {:reply, {file_path, fd}, put(state, {file_path, fd})}
  end

  def handle_call(:tracked, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:cleanup, _from, state) do
    {removed, failed} = cleanup(state)
    {:reply, removed, Enum.into(failed, set())}
  end

  @impl GenServer
  def terminate(_reason, state) do
    cleanup(state)
    :ok
  end

  defp cleanup(state) do
    {removed, failed} =
      Enum.reduce(state, {[], []}, fn {path, fd}, {removed, failed} ->
        File.close(fd)

        case File.rm_rf(path) do
          {:ok, _} -> {[path | removed], failed}
          _ -> {removed, [path | failed]}
        end
      end)

    {:lists.reverse(removed), :lists.reverse(failed)}
  end
end
