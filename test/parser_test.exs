defmodule ParserTest do
  use ExUnit.Case

  doctest Servy.Parser
  alias Servy.Parser

  test "parses a list of header fields into a map" do
    header_lines = ["A: 1", "B: 2"]

    IO.inspect(header_lines)
    headers = Parser.parse_headers(header_lines, %{})
    IO.inspect headers
    assert headers == %{"A" => "1", "B" => "2"}
  end

end
