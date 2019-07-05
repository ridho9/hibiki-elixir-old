defmodule LineSDK.Client do
  @line_api_url Application.get_env(:line_sdk, :api_url)

  defstruct channel_access_token: nil, channel_secret: nil
  @type t :: %LineSDK.Client{channel_access_token: binary, channel_secret: binary}

  defp get(client, url) do
    headers = [
      {"Authorization", "Bearer #{client.channel_access_token}"}
    ]

    HTTPoison.get(@line_api_url <> url, headers)
  end

  defp post(client, url, data) do
    headers = [
      {"Authorization", "Bearer #{client.channel_access_token}"},
      {"Content-Type", "application/json"}
    ]

    HTTPoison.post(@line_api_url <> url, data, headers)
  end
end
