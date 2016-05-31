defmodule Rumbl.Counter do  
  def inc(pid), do: Agent.update(pid, &(&1 + 1))
  def dec(pid), do: Agent.update(pid, &(&1 - 1))
  def val(pid), do: Agent.get(pid, &(&1))
  def start_link(initial_val) do    
    Agent.start_link(fn -> initial_val end)
  end
end
