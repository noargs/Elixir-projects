# Identicon

An Elixir library to generate GitHub like symmetrical 5X5 grid of squares' identicon from a string

### i.e.
"Keyword" to png picture

### What is identicon
An Identicon is a visual representation of a hash value, usually of an IP address, that serves to identify a user of a computer system as a form of avatar while protecting the user's privacy... [see the wikipedia](https://en.wikipedia.org/wiki/Identicon)


## Installation

- Clone the Identicon repository through terminal
`$ git clone https://noargs@bitbucket.org/noargs/identicon.git`


- Move into project directory
`$ cd identicon`


- Install project dependencies
`$ mix deps.get`


- Run the identicon project in elixir shell
`$ iex -S mix`


- In elixir shell type following to get identicon of "fox"
`iex> Identicon.main("fox")`

- Identicon of "fox" will be generated inside identicon directory with name `fox.png`





Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/identicon](https://hexdocs.pm/identicon).