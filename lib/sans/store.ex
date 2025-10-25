defmodule Sans.Store do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(id) do
    Agent.get(__MODULE__, &Map.get(&1, id))
  end

  def put(text) do
    id = :crypto.strong_rand_bytes(6) |> Base.url_encode64() |> binary_part(0, 6)
    Agent.update(__MODULE__, &Map.put(&1, id, text))
    id
  end
end
