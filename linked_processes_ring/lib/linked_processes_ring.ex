defmodule LinkedProcessesRing do
  @moduledoc """
  ##[Background]

  Little background knowledge before demonstrating the **Chain reaction of exit signals** using
  this `LinkedProcessesRing` module

  - When process links to another, it creates a bidirectional relationship
  - A linked process has a link set, which contains all the process it's linked to
  - If either process terminates for some reason, an exit signal is propagated to all
    the processes its linked to
  - If any of these processes is linked to a different set of processes, then same exit
    signal is propagated along, too

  [Linking Processes]
  - A link is created using `Process.link/1`, the sole argument being the process id (pid)
    of the process to link to
  - *This means `Process.link/1` must be called from within an existing process.*
  - Because there's no such thing as Process.link(link_from, link_to) **X**

  [Example]
  - Open `iex` session, and you will create a process that will link to iex shell process
  - Whenever you invoke `Process.link/1` from the shell, `Process.link/1` will run under the context of iex shell
  - Same is true for `Process.monitor/1`
  - The process will crash when you send it a :crash message

  **iex>** self()
  - you can inspect the current link set of the shell process

  **iex>** `Process.info(self, :links)`

  - Process.info/1 also contains other useful information but we only care about links `Process.info(self, :links)`
  - Next, let's make a process that only responds to a *:crash* message:

  **iex>** `pid = spawn(fn -> receive do: crash -> 1/0 end end)`

  - Link the shell process to the process you just created:

  **iex>** `Process.link(pid)`

  - you can test both process link sets contains pid of each other

  **iex>** `Process.info(self, :links)`

  **iex>** `Process.info(pid, :links)`

  - When you send the `:crash` message to pid process from shell you will see both shell and pid process will terminated

  **iex>** `send(pid, :crash)`
  """



  def create_processes(n) do
    1..n |> Enum.map(fn _ -> spawn(fn -> loop() end) end)
  end



  def loop() do
    receive do
      {:link, link_to} when is_pid(link_to) ->
        Process.link(link_to)
        loop()

      :trap_exit ->
        Process.flag(:trap_exit, true)
        loop()

      :crash ->
        1/0

      {:Exit, pid, reason} ->
        IO.puts "#{inspect self()} received {:EXIT, #{inspect pid}, #{reason}"
        loop()
    end
  end


  def link_processes(procs) do
    link_processes(procs, [])
  end

  def link_processes([proc_1, proc_2|rest], linked_processes) do
    send(proc_1, {:link, proc_2})
    link_processes([proc_2|rest], [proc_1|linked_processes])
  end

  def link_processes([proc|[]], linked_processes) do
    first_process = linked_processes |> List.last
    send(proc, {:link, first_process})
    :ok
  end


end























