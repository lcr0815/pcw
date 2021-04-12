defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests, this line documents the module"

  @pages_path Path.expand("../../pages", __DIR__)

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

  import Servy.Plugins, only: [log: 1, rewrite_path: 1, track: 1]
  import Servy.Parser

  @doc "transforms the request into a response, this documents the immedaite function below"
  def handle(request)   do
    request
    |> parse
    |> rewrite_path
    |> route
    |> track
    |> format_response

  end

  def route(%Conv{method: "GET", path: "/snapshots"} = conv) do

    parent = self()

    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-1")})end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-2")})end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-3")})end)

    snapshot1 = receive do {:result, filename} -> filename end
    snapshot2 = receive do {:result, filename} -> filename end
    snapshot3 = receive do {:result, filename} -> filename end

    snapshots = [ snapshot1, snapshot2, snapshot3 ]

    %{ conv | status: 200, response_body: inspect snapshots}
  end

  @doc """
  this route simulates an error crash
  """
  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  # @doc """
  # this route function hibernates for x amount of time
  # """
  def route(%Conv{method: "GET", path:  "/hibernate/" <> time} = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, response_body: "Awake!" }
  end

  def route(%Conv{method: "GET", path:  "/wildthings"} = conv) do
    %{ conv | status: 200, response_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{method: "GET", path:  "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path:  "/bears"} = conv) do
    # %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path:  "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  # name=Baloo%type=Brown
  def route(%Conv{method: "POST", path:  "/bears" } = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path:  "/about"} = conv) do
      @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv), do: %{ conv | status: 404, response_body: "No #{path} here"}

  def handle_file({:ok, content},    conv), do: %{ conv | status: 200, response_body: content }
  def handle_file({:error, :enoent}, conv), do: %{ conv | status: 404, response_body: "File not found" }
  def handle_file({:error, reason},  conv), do: %{ conv | status: 500, response_body: "File error: #{reason}" }

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.response_body)}\r
    \r
    #{conv.response_body}
    """
  end
end
