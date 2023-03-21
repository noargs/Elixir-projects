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


  # inspect the contents of stats (access the server state)
  # since this function is call to `GenServer.call` therefore its synchronous
  #
  def get_stats(pid) do
    GenServer.call(pid, :get_stats)
  end




  # Valid return values for init/1
  # - {:ok, state} ✓ we are using this for simplicity, state initialised to empty map %{}
  # - {:ok, state, timeout}
  # - :ignore
  # - {:stop, reason}
  def init(:ok) do
    {:ok, %{}}
  end


  def get_temperature(pid, location) do

    # GenServer.call/3 expects a handle_call/3 defined in this module (i.e. __MODULE__) and invokes it accordingly
    # GenServer.call/3 makes a synchronous request to the server
    # This means reply from the server is expected
    GenServer.call(pid, {:location, location})
  end


  # get_stats(pid) call
  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end



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
        Map.update!(old_stats, location, &(&1 + 1))      # Map.update!(old_stats, location, fn(val) -> val + 1 end)
#        IO.inspect "true case"
#        IO.put old_stats
#        IO.put location
      false ->
        Map.put_new(old_stats, location, 1)
#        IO.inspect "false case"
#        IO.put old_stats
#        IO.put location
    end
  end

  defp api_key() do
    System.get_env("WEATHER_API")
  end
  
end
