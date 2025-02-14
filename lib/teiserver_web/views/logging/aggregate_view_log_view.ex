defmodule TeiserverWeb.Logging.AggregateViewLogView do
  use TeiserverWeb, :view

  def view_colour(), do: Teiserver.Logging.AggregateViewLogLib.colours()
  # def gradient(), do: {"#112266", "#6688CC"}
  def icon(), do: Teiserver.Logging.AggregateViewLogLib.icon()

  def convert_load_time(load_time) do
    round(load_time / 10) / 100
    |> to_string
  end

  def heatmap(value, maximum, "green-red") do
    percentage = value / max(maximum, 1)

    [
      105 + percentage * 150,
      105 + (150 - percentage * 150),
      50
    ]
    |> Enum.map_join(fn colour ->
      colour
      |> round
      |> Integer.to_string(16)
      |> to_string
      |> String.pad_leading(2, "0")
    end)
  end

  def heatmap(value, maximum, "red-green") do
    percentage = value / max(maximum, 1)

    [
      105 + (150 - percentage * 150),
      105 + percentage * 150,
      50
    ]
    |> Enum.map_join(fn colour ->
      colour
      |> round
      |> Integer.to_string(16)
      |> to_string
      |> String.pad_leading(2, "0")
    end)
  end

  def heatmap(value, maximum, "white-green") do
    percentage = value / max(maximum, 1)

    [
      255 - percentage * 200,
      255,
      255 - percentage * 200
    ]
    |> Enum.map_join(fn colour ->
      colour
      |> round
      |> Integer.to_string(16)
      |> to_string
      |> String.pad_leading(2, "0")
    end)
  end

  def heatmap(value, maximum, "black-red") do
    percentage = value / max(maximum, 1)

    [
      (percentage * 255),
      (percentage * 25),
      (percentage * 25)
    ]
    |> Enum.map_join(fn colour ->
      colour
      |> round
      |> Integer.to_string(16)
      |> to_string
      |> String.pad_leading(2, "0")
    end)
  end
end
