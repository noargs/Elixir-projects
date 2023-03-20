# WeatherHttpoison

**Weather API with Httpoison and Json**

## Installation


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



