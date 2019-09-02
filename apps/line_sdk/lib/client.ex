defmodule LineSDK.Client do
  @line_api_url "https://api.line.me/v2"

  defstruct channel_access_token: nil, channel_secret: nil
  @type t :: %LineSDK.Client{channel_access_token: binary, channel_secret: binary}

  def send_reply(client, reply_token, %{} = message),
    do: send_reply(client, reply_token, [message])

  def send_reply(client, reply_token, messages) do
    body = %{
      "reply_token" => reply_token,
      "messages" => messages
    }

    post(client, "/bot/message/reply", body)
  end

  @spec get_profile(%LineSDK.Client{}, binary) :: {:error, any} | {:ok, any}
  def get_profile(client, user_id) do
    user_id = URI.encode(user_id)

    with {:ok, %HTTPoison.Response{body: body, status_code: status_code}} <-
           get(client, "/bot/profile/#{user_id}"),
         {:ok, body} <- Jason.decode(body) do
      case status_code do
        200 -> {:ok, body}
        404 -> {:error, body["message"]}
        _ -> {:error, body}
      end
    end
  end

  @spec get_content(LineSDK.Client.t(), String.t()) :: {:ok, binary} | {:error, any}
  def get_content(client, message_id) do
    with {:ok, %HTTPoison.Response{body: body, status_code: 200}} <-
           get(client, "/bot/message/#{message_id}/content") do
      {:ok, body}
    end
  end

  def get(client, url) do
    headers = [
      {"Authorization", "Bearer #{client.channel_access_token}"}
    ]

    HTTPoison.get(@line_api_url <> url, headers)
  end

  def post(client, url, data) do
    headers = [
      {"Authorization", "Bearer #{client.channel_access_token}"},
      {"Content-Type", "application/json"}
    ]

    data = Recase.Enumerable.convert_keys(data, &Recase.to_camel/1)

    with {:ok, data} <- Jason.encode(data) do
      HTTPoison.post(@line_api_url <> url, data, headers)
    end
  end
end
