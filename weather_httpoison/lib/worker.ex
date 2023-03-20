defmodule WeatherHttpoison.Worker do
  @moduledoc """
  `WeatherHttpoison.Worker` job is to fetch the temperature
  of a given location from OpenWeatherMap and parse the results.
  """


  def temperature_of(location) do
    location
    |> url_for
    |> HTTPoison.get
    |> parse_response
    |> case do
         {:ok, temp} ->
           "Today in #{location |> city_in}: #{temp}°C"
         :error ->
           "#{location |> city_in} not found"
       end
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> weather_report
  end

  defp parse_response(_) do
    :error
  end
  
  defp weather_report(json) do
    try do
      temp = json["main"]["temp"] |> compute_temperature
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp compute_temperature(temperature) do
    (temperature - 273.15) |> Float.round(1)
  end

  defp city_in(location) do
    location_list = String.split(location, ", ")
    [city | _country] = location_list
    city
  end

  defp api_key() do
    System.get_env("WEATHER_API")
  end

end
