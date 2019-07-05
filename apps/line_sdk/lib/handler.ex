defmodule LineSDK.Handler do
  @callback handle(event :: LineSDK.Models.WebhookEvent.event(), client :: LineSDK.Client.t()) ::
              {:ok} | {:error, reason :: term}
end
