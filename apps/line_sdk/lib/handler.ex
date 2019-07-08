defmodule LineSDK.Handler do
  @callback handle(event :: LineSDK.Models.WebhookEvent.event(), opts :: keyword()) ::
              {:ok} | {:error, reason :: term}
end
