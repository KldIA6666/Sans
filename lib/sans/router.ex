defmodule Sans.Router do
  use Plug.Router
  import Plug.Conn

  plug Plug.Parsers, parsers: [:urlencoded]
  plug :match
  plug :dispatch

  get "/" do
    conn |> put_resp_content_type("text/html") |> send_resp(200, page_html("", ""))
  end

  post "/" do
    text = conn.params["text"] || ""
    action = conn.params["action"]

    case action do
      "preview" ->
        {:ok, preview_html, []} = Earmark.as_html(text)
        conn |> put_resp_content_type("text/html") |> send_resp(200, page_html(text, preview_html))

      "create" ->
        id = Sans.Store.put(text)
        conn |> put_resp_header("location", "/#{id}") |> send_resp(302, "Redirecting...")
    end
  end

  get "/:id" do
    case Sans.Store.get(id) do
      nil ->
        conn |> send_resp(404, "Sans Not Found")
      text ->
        {:ok, preview_html, []} = Earmark.as_html(text)
        conn |> put_resp_content_type("text/plain") |> send_resp(200, preview_html)
    end
  end

  match _ do
    conn |> send_resp(404, "Not Found")
  end

  defp page_html(current_text, preview_html) do
  """
  <!DOCTYPE html>
  <html>
  <head>
    <title>Sans</title>
    <style>
      body {
        font-family: monospace;
        margin: 0;
        height: 100vh;
        display: flex;
        flex-direction: column;
        background-color: #f0f0f0;
      }

      .container {
        display: flex;
        flex-grow: 1;
        height: 100%;
      }

      .panel {
        flex: 1;
        padding: 1rem;
        border-right: 2px solid black;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        background-color: white;
      }

      .panel:last-child {
        border-right: none;
      }

      h2 {
        margin-top: 0;
        border-bottom: 2px solid black;
        padding-bottom: 0.5rem;
      }

      textarea {
        flex-grow: 1;
        resize: none;
        width: 100%;
        box-sizing: border-box;
        font-family: monospace;
        padding: 0.5rem;
        border: 2px solid black;
      }

      .buttons {
        margin-top: 1rem;
        display: flex;
        gap: 1rem;
      }

      button {
        padding: 0.5rem 1rem;
        font-family: monospace;
        cursor: pointer;
        font-weight: bold;
        border: 2px solid black;
        background: #eee;
      }

      button:hover {
        background: #ddd;
      }

      .preview-content img {
        max-width: 100%;
      }

      /* Added this style for the preview placeholder */
      .preview-placeholder {
        color: #777;
        font-style: italic;
      }
    </style>
  </head>
  <body>
    <form action="/" method="post" style="height: 100%; display: flex; flex-direction: column;">
      <div class="container">

        <div class="panel">
          <h2>INPUT</h2>

          <textarea name="text" spellcheck="false">#{current_text}</textarea>

          <div class="buttons">
            <button type="submit" name="action" value="preview">PREVIEW</button>
            <button type="submit" name="action" value="create">CREATE</button>
          </div>
        </div>

        <div class="panel">
          <h2>PREVIEW</h2>
          <div class="preview-content">
            #{preview_html}
          </div>
        </div>

        <div class="panel">
          <h2>HOW-TO</h2>
          <p>Use Markdown in the input panel.</p>
          <ul>
            <li><code># Heading 1</code></li>
            <li><code>## Heading 2</code></li>
            <li><code>**Bold Text**</code></li>
            <li><code>*Italic Text*</code></li>
            <li><code>[Link](https://example.com)</code></li>
            <li><code>- List Item</code></li>
          </ul>
        </div>

      </div>
    </form>
  </body>
  </html>
  """
  end
end
