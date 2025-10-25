defmodule Sans.Router do
  use Plug.Router
  import Plug.Conn

  plug Plug.Parsers, parsers: [:urlencoded]
  plug :match
  plug :dispatch

  get "/" do
    conn |> put_resp_content_type("text/html") |> send_resp(200, page_html())
  end

  post "/" do
    text = conn.params["text"]
    id = Sans.Store.put(text)
    conn |> put_resp_header("location", "/#{id}") |> send_resp(302, "Loading...")
  end

  get "/:id" do
    case Sans.Store.get(id) do
      nil ->
        conn |> send_resp(404, "Sans Not Found")
      text ->
        conn |> put_resp_content_type("text/plain") |> send_resp(200, text)
    end
  end

  match _ do
    conn |> send_resp(404, "404")
  end

  defp page_html do
  """
  <!DOCTYPE html>
  <html>
    <head>
      <title>Sans</title>
    </head>
    <body>
      <h1>Create a new entry</h1>
      <form action="/" method="post">
        <textarea name="text" rows="10" cols="50"></textarea>
        <br>
        <button type="submit">Create</button>
      </form>
    </body>
  </html>
  """
  end
end
