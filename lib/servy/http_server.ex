defmodule Servy.HttpServer do

# server() ->
#   {ok, LSock} = gen_tcp:listen(5678, [binary, {packet, 0},
#                                       {active, false}]),
#   {ok, Sock} = gen_tcp:accept(LSock),
#   {ok, Bin} = do_recv(Sock, []),
#   ok = gen_tcp:close(Sock),
#   Bin.

  def server do

    {:ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0, active: false])
    {:ok, sock} = :gen_tcp.accept(lsock)
    {:ok, bin} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)
    bin

  end

  def start(port) when is_integer(port) and port > 1023 do
    # Creates a socket to listen for client connections,
    # `listen_socket` is bound to the listening socket.
    IO.puts "\x1b[31m\x1b[47m\x1b[5m\x1b[4mWht the hell\x1b[0m"
    {:ok, listen_socket} =
      :gen_tcp.listen(port,  [:binary, packet: :raw, active: false, reuseaddr: true])

    # Socket options (don't worry about these details):
    # `:binary` - open the socket in "binary" mode and delliver data as binaries
    # `packet: :raw` - deliver the entire binary without doing any packet handling
    # `active: false` - receive data when we're ready by calling `:gen_tcp.recv/2`
    # `reuseaddr: true` - allows reusing the address if the listener crashes

    IO.puts "\n🎧 Listening for connection requests on port #{port}..."

    accept_loop(listen_socket)
    end

    def accept_loop(listen_socket) do
      IO.puts "⏳ Waiting to accept a client connection"
      # Suspends (blocks) and waits for a client connection.
      # When a connection is accepted, `client_socket` is bound to a new client socket.
      {:ok, client_socket} = :gen_tcp.accept(listen_socket)

      IO.puts "⚡ connection accepted!\n"

      # receives the request and sends a response over the client socket.
      spawn(fn -> serve(client_socket) end)

      # loop back to wait and accept the next connection
      accept_loop(listen_socket)
    end

    @doc """
    Receives the reuqest on the `client_socket` and
    sends a response back over the same socket.
    """
    def serve(client_socket) do
      client_socket
        |> read_request
        |> Servy.Handler.handle
        |> write_response(client_socket)
    end

    @doc """
    Receives a request on the `client_socket`.
    """
    def read_request(client_socket) do
      {:ok, request} = :gen_tcp.recv(client_socket, 0) # all available bytes

      IO.puts "-> received request:\n"
      IO.puts request

      request
    end

    @doc """
    returns a generic HTTP response.
    """
    def generate_response(_request) do
      """
      HTTP/1.1 200 OK\r
      Content-Type: text/plain\r
      Content-Length: 6\r
      \r
      Hello!
      """
    end

    @doc """
    Sends the `response` over the `client_socket`.
    """
    def write_response(response, client_socket) do
      :ok = :gen_tcp.send(client_socket, response)

      IO.puts "<= Sent response:\n"
      IO.puts response

      # closes the client socket, ending the connection.
      # does not close the listen socket!
      :gen_tcp.close(client_socket)
    end
end
