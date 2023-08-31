defmodule Temp.Tracker do
  use GenServer

  if :application.get_key(:elixir, :vsn) |> elem(1) |> to_string() |> Version.match?("~> 1.1") do
    defp set(), do: MapSet.new()
    defdelegate put(set, value), to: MapSet
  else
    defp set(), do: HashSet.new()
    defdelegate put(set, value), to: HashSet
  end

  def init(_args) do
    Process.flag(:trap_exit, true)
    {:ok, set()}
  end

  def handle_call({:add, item}, _from, state) do
    {:reply, item, put(state, item)}
  end

  def handle_call(:tracked, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:cleanup, _from, state) do
    {removed, failed} = cleanup(state)
    {:reply, removed, Enum.into(failed, set())}
  end

  def terminate(_reason, state) do
    cleanup(state)
    :ok
  end

  defp cleanup(state) do
    {removed, failed} =
      state
      |> Enum.reduce({[], []}, fn {path, fd}, {removed, failed} ->
        File.close(fd)

        case File.rm_rf(path) do
          {:ok, _} -> {[path | removed], failed}
          _ -> {removed, [path | failed]}
        end
      end)

    {:lists.reverse(removed), :lists.reverse(failed)}
  end
end
