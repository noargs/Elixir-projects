defmodule HiSupervisor do
  @moduledoc """
  Documentation for `HiSupervisor`.
  """

  use GenServer


  @doc """
  - This is the main entry point to creating a supervisor process.
  - Here, you call `GenServer.start_link/2` with the name of the *module* and pass in a *list* with a single element of `child_spec_list`.
  - `child_spec_list` specifies a (potentially empty) list of child specifications.
  - This is a fancy way of telling the supervisor what kinds of processes it should manage
  - A child specification for two (similar) workers could look like this:

    `[{HiWorker, :start_link, []}, {HiWorker, :start_link, []}]`

  - Recall that `GenServer.start_link/2` expects the `HiSupervisor.init/1` callback to be implemented.
  - It passes the second argument (the list i.e. [child_spec_list]) into `:init/1`
  """
  def start_link(child_spec_list) do
    GenServer.start_link(__MODULE__, [child_spec_list])
  end

  @doc """
  - `Process.flag(:trap_exit, true)` makes the supervisor process trap exist i.e. a system process,
     receive exit signal as normal messages

  - `start_children/1` spawn the child processes and returns a list of tuples i.e.
    [{<0.56.0>, {HiSupervisor, :init, []}}, {<0.57.0>, {HiSupervisor, :init, []}}]
    Each tuple is a pair that contains the pid of the newly spawned child and the child specification

  - This list is then fed into Enum.into/2. By passing in HashDict.new as the second argument, `Enum.into(HashDict.new)`
  - you’re effectively transforming the list of tuples into a HashDict, with the pids of the child processes as
    the keys and the child specifications as the values
  - `HashDict` knows if it gets a tuple the first element becomes the key and second element becomes the value

  **iex>**  h = [{:pid1, {:mod1, :fun1, :arg1}}, {:pid2, {:mod2, :fun2, :arg2}}]
            |> Enum.into(HashDict.new)

  - this returns a **HashDict**
  \#HashDict<[pid2: {:mod2, :fun2, :arg2}, pid1: {:mod1, :fun1, :arg1}]>

  - The Key can be retrieved like so:

   **iex>** HashDict.fetch(h, :pid2)
   `{:ok, {:mod2, :fun2, :arg2)}`

  """
  def init([child_spec_list]) do
    Process.flag(:trap_exit, true)
    state = child_spec_list
              |> start_children
              |> Enum.into(HashDict.new)
  end

end
