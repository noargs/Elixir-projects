defmodule Identicon do

  @doc """
  take argument "input" as a string

      Identicon.main("hello")
      |> hash_input()

      250 px horizontal and 250px vertical triangle

                          left side    |     right side
                                       |   mirror left side
                        < ----- ---- 250px ----- ----->
                        <50px>         |
                        _______________________________       +
    [93, 65, 64,        |  1  |  2  |  3  |  2  |  1  |       |
                        | 93  |  65 |  64 |  65 |  93 |       |
                        -------------------------------       |
     42, 188, 75,       |  4  |  5  |  6  |  5  |  4  |       |
                        | 42  | 188 |  75 | 188 |  42 |       |
                        -------------------------------
     42, 118, 185,      |  7  |  8  |  9  |  8  |  7  |      250px
                        |  42 | 118 | 185 | 118 |  42 |
                        -------------------------------       |
     113, 157, 145,     | 10  |  11  | 12 |  11 |  10 |       |
                        | 113 |  157 | 145| 157 | 113 |       |
                        -------------------------------       |
     16, 23, 197,       | 13  |  14  | 15 |  14 |  13 |       |
                        | 16  |  23  | 197|  23 |  16 |       |
                        -------------------------------       +
     146]                               |
                                        |

         - last 16th element in the list which is 146 will be discarded
         - first three element will be used for RGB 93, 65, 64

  """
  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_image()
    |> save_image(input)
  end


  @doc """
  hash = :crypto.hash(:md5, "hello")
  <<93, 65, 64, 42, 188, 75, 42, 118, 185, 113, 157, 145, 16, 23, 197, 146>>

  :binary.bin_to_list(hash)
  [93, 65, 64, 42, 188, 75, 42, 118, 185, 113, 157, 145, 16, 23, 197, 146]

  Base.encode16(hash)
  "5D41402ABC4B2A76B9719D911017C592"
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end


  @doc """
  Only pick first three elements in the list [93, 65, 64]
  to create RGB

  function head can also be changed like
      def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image)
  """
  def pick_color(%Identicon.Image{hex: hex_list} = image) do
    [r, g, b | _tail] = hex_list

    %Identicon.Image{image | color: {r, g, b}}
  end


  def build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid =
      hex_list
        |> Enum.chunk_every(3, 3, :discard)
        |> Enum.map(&mirror_row/1)
        |> List.flatten()
        |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end


  @doc """
  Take each row i.e. list as an argument
  Take row/list [93, 65, 64] and returns [93, 65, 64, 65, 93]
  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end


  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end


  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn ({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn ({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end


end















