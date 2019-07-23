defmodule LineSDK.Client do
  @line_api_url Application.get_env(:line_sdk, :api_url)

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

  defp get(client, url) do
    headers = [
      {"Authorization", "Bearer #{client.channel_access_token}"}
    ]

    HTTPoison.get(@line_api_url <> url, headers)
    |> process_api_response
  end

  defp post(client, url, data) do
    headers = [
      {"Authorization", "Bearer #{client.channel_access_token}"},
      {"Content-Type", "application/json"}
    ]

    data = Recase.Enumerable.convert_keys(data, &Recase.to_camel/1)

    HTTPoison.post(@line_api_url <> url, Jason.encode!(data), headers)
    |> process_api_response
  end

  defp process_api_response({:error, _} = resp), do: resp

  defp process_api_response({:ok, resp}) do
    case resp do
      %{status_code: 200} -> {:ok}
      _ -> {:error, Jason.decode!(resp.body)}
    end
  end
end
