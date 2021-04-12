defmodule Servy.VideoCam do
  @doc """
  simulates sendig a request to an external API
  to get a snapshot image from a video camera.
  """
  def get_snapshot(camera_name) do

    # System.cmd("imagesnap", ["-w 2", "#{camera_name}-snapshit.jpg"])

    # Sleep for  1 second to simulate the API can be slow:
    :timer.sleep(1000)

    #Example response returned from the API
    "#{camera_name}-snapshot.jpg"
  end
end
