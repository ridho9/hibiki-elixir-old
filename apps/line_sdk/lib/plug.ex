defmodule LineSDK.Plug do
  use Plug.Builder

  plug(:check_signature_exists)
  plug(:check_json)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["text/*"],
    body_reader: {LineSDK.Plug, :cache_body, []},
    json_decoder: Jason
  )

  plug(:check_signature_match, builder_opts())
  plug(:handle_message, builder_opts())

  def init(opts) do
    client = %LineSDK.Client{
      channel_access_token: opts[:channel_access_token],
      channel_secret: opts[:channel_secret]
    }

    %{
      client: client,
      handler: opts[:handler]
    }
  end

  def check_signature_exists(conn, _opts) do
    if get_req_header(conn, "x-line-signature") == [] do
      conn
      |> send_resp(401, "missing x-line-signature")
      |> halt()
    else
      conn
    end
  end

  def check_json(conn, _opts) do
    [content_type] = get_req_header(conn, "content-type")

    if String.starts_with?(content_type, "application/json") do
      conn
    else
      conn
      |> send_resp(400, "is not json")
      |> halt()
    end
  end

  def check_signature_match(conn, %{client: client}) do
    raw_body = conn.assigns.raw_body
    [signature] = get_req_header(conn, "x-line-signature")

    if LineSDK.Auth.signature_match?(raw_body, client.channel_secret, signature) do
      conn
    else
      conn
      |> send_resp(404, "invalid signature")
      |> halt
    end
  end

  def handle_message(conn, opts) do
    events = conn.body_params["events"]

    events
    |> Enum.map(fn event ->
      opts.handler.handle(event, client: opts.client)
    end)

    conn
    |> send_resp(200, "")
  end

  def cache_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
    {:ok, body, conn}
  end
end
