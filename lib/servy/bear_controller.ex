defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  @templates_path Path.expand("../../templates", __DIR__)

  defp render(conv, template, bindings \\ []) do

    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{ conv | status: 200, response_body: content }

  end
  def index(conv) do

    IO.puts "the templates are in: #{@templates_path}"

    bears =
        Wildthings.list_bears()
      |> Enum.sort(&Bear.order_by_name/2)

    render(conv, "index.eex", bears: bears)
    end

  #destructuring a varialble eample
  def show(conv,%{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{ "name" => name, "type" => type }) do
    %{ conv | status: 201,
    response_body: "Created a #{type} bear named #{name}!" }
  end
end
