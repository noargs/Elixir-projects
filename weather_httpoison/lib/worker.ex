defmodule WeatherHttpoison.Worker do
  @moduledoc """
  `WeatherHttpoison.Worker` job is to fetch the temperature
  of a given location from OpenWeatherMap and parse the results.
  """


  def temperature_of(location) do
    location
    |> url_for(location)
  end

  defp url_for(location) do
    URI.encode()
  end

end
