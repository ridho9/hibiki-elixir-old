defmodule Hibiki.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Hibiki is running!")
  end

  forward("/callback",
    to: LineSDK.Plug,
    init_opts: [
      channel_access_token: Application.get_env(:hibiki, :channel_access_token),
      channel_secret: Application.get_env(:hibiki, :channel_secret),
      handler: Hibiki.Handler
    ]
  )

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
