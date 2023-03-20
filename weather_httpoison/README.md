# WeatherHttpoison

**Weather API with Httpoison and Json**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `weather_httpoison` to your list of dependencies in `mix.exs`:
- Add following dependencies to your `mix.exs` file
      
```elixir
def deps do
  [
    {:httpoison, "~> 2.0"},
    {:json, "~> 1.4"}
  ]
end
```
    
- run `mix deps.get` to fetch the dependencies
- add `:httpoison` to your `application` function in `mix.exs` as follows   
    
```elixir
def application do
  [applications: [:httpoison]]
end
```
     
- obtain API key from [OpenWeatherMap](https://openweathermap.org) 

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/weather_httpoison>.

