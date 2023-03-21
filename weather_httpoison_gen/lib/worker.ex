defmodule WeatherHttpoisonGen.Worker do
  use GenServer

  def start_link(opts \\ []) do
    # `init(args)` is invoked when GenServer.start_link/3 is called
    # start_link/3 takes the module name (i.e. __MODULE__)
    # of GenServer implementation where the init/1 callback is defined
    # it will start the process and links the server process to the parent process
    # therefore if server process fails, the parent process is notified
    # second argument (i.e. :ok) is there to be passed to init/1
    # final argument is a list of options to be passed to GenServer.start_link/3
    # i.e. defining a name to register the process and enable extra debugging information
    # when start_link/3 is called it invokes MyModule.init/1
    # it waits until MyModule.init/1 has returned before returning
    GenServer.start_link(__MODULE__, :ok, opts )
  end



  # Valid return values for init/1
  # - {:ok, state} ✓ we are using this for simplicity, state initialised to empty map %{}
  # - {:ok, state, timeout}
  # - :ignore
  # - {:stop, reason}
  def init(:ok) do
    {:ok, %{}}
  end



  # inspect the contents of stats (access the server state)
  # since this function is call to `GenServer.call` therefore its synchronous
  # and we expect a reply from server
  def get_stats(pid) do
    GenServer.call(pid, :get_stats)
  end



  # reset the state i.e. previous state map %{"Dublin" => 2, "London" => 1}
  # back to %{}
  def reset_stats(pid) do
    GenServer.cast(pid, :reset_stats)
  end



  # [Stopping the server] to free up resources or perform cleanup tasks
  # we used GenServer.cast which asynchronous because we didnt care about a return value
  # another reason could be that the server takes time to properly clean up all resources
  # and we don't want to wait
  def stop(pid) do
    GenServer.cast(pid, :stop)
  end



  # if any clean up required must be done in `GenServer.terminate/2` callback
  # as follows
  def terminate(reason, stats) do
    # We could write to a file, database etc
    IO.puts "Server terminated because of #{inspect reason}"
      inspect stats
    :ok
  end



  def get_temperature(pid, location) do

    # GenServer.call/3 expects a handle_call/3 defined in this module (i.e. __MODULE__) and invokes it accordingly
    # GenServer.call/3 makes a synchronous request to the server
    # This means reply from the server is expected
    GenServer.call(pid, {:location, location})
  end



  ## handle_calls go here


  # messages may arrive from process that aren't defined in handle_call or _cast
  # thats where handle_info/2 comes in.
  # it invoked to handle any other messages, that are received by the process
  # sometimes referred to as out-of-band messages
  # you don't need to supply client API counterpart for handle_info/2
  def handle_info(msg, stats) do
    IO.puts "received #{inspect msg}"
    {:noreply, stats}
  end



  # get_stats(pid) call
  # in synchronous call (GenServer.call) we expect reply from server
  # Notice that messages can come in the form of any valid Elixir term
  # i.e. tuples, lists, and atoms
  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end



  # for get_temperature(pid, location) call
  # [first argument] declares the expected request to be handled
  # [second argument] returns a tuple in the form of {pid, tags},
  # `pid` is the pid of the client and `tag` is unique reference to the message
  # [Third argument], `state` represents the internal state of the server
  # in our case its the current frequency counts of valid locations
  def handle_call({:location, location}, _from, stats) do
    case temperature_of(location) do                        # Makes a request to the API for location's temperature
      {:ok, temp} ->
        new_stats = update_stats(stats, location)           # Updates the stats Map with the location frequency
        {:reply, "#{temp}°C", new_stats}                    # Returns a three element tuple as a response (as mentioned in GenServer Callback table page:68)
      _ ->
        {:reply, :error, stats}                             # Returns a three-element tuple that has an :error tag
    end
  end



  # for reset_stats(pid) call
  # it asynchronous call to server (Through `GenServer.cast`)
  # therefore no reply is expected
  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end



  # according to the table in handle_call/handle_cast rows, two valid responses for :stop
  # {:stop, reason, new_state}
  # {:stop, reason, reply, new_state}
  # if any clean up required must be done in `GenServer.terminate/2` callback
  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end



  # Helper functions
  defp temperature_of(location) do
    location |> url_for |> HTTPoison.get |> parse_response
  end



  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key()}"
  end



  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode!() |> compute_temperature
  end



  defp parse_response(_) do
    :error
  end



  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end



  defp update_stats(old_stats, location)do
    case Map.has_key?(old_stats, location) do
      true ->
        # if Dublin and London entered for temperature
        # And Dublin entered twice (x2) this counter for Dublin will go up
        # i.e. %{"Dublin" => 2, "London" => 1}
        Map.update!(old_stats, location, &(&1 + 1))      # Map.update!(old_stats, location, fn(val) -> val + 1 end)

      false ->
        Map.put_new(old_stats, location, 1)
    end
  end



  defp api_key() do
    System.get_env("WEATHER_API")
  end
  
end
