defmodule Identicon.Image do

  @moduledoc """
  > %Identicon.Image{}
  %Identicon.Image{hex: nil}

  > %Identicon.Image{hex: []}
  %Identicon.Image{hex: []}

  > %Identicon.Image{what: []}
  (KeyError) key :what not found in %Identicon.Image{hex: nil}

  OR we can define struct like below
  defstruct[:hex, :color, :y] instead of defstruct hex: nil, :color
  """
  defstruct hex: nil, color: nil, grid: nil, pixel_map: nil

end
