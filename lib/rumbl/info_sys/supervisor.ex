defmodule Rumbl.InfoSys.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    # since this is a simple_one_for_one supervisor it can only have
    # one child. This is one that is used when we call the
    #
    # Supervisor.start_child(pid_of_this_supervisor, params_fed_to_the_childs_start_link)
    
    children = [ worker(Rumbl.InfoSys, [], restart: :temporary) ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
