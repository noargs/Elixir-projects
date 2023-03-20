defmodule WeatherHttpoison do
  @moduledoc """
  WeatherHttpoison to spin the Coordinator process
  which is there to keep state and process the results
  get back from Worker process

  WeatherHttpoison.weather_in(cities) will first initialise
  Coordinator process and then initialise as many Worker processes
  as cities,

  Each iteration send `city` name and `pid` of Coordinator to Worker
  process so that Coordinator can receive messages from Worker process
  and process the results (i.e. sorting, keeping track of state as how many
  messages yet to come before exiting `:exit` from process
  """


  def weather_in(cities) do

    coordinator_pid = spawn(
      WeatherHttpoison.Coordinator,
      :loop,
      [[], Enum.count(cities)]
    )

    cities |> Enum.each(fn city ->
      worker_pid = spawn(WeatherHttpoison.Worker, :loop, [])
      send(worker_pid, {coordinator_pid, city})
    end)
  end

end
