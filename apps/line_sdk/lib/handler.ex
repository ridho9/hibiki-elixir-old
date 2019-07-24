defmodule LineSDK.Handler do
  @callback handle(event :: any(), opts :: keyword()) ::
              {:ok} | {:error, reason :: term}
end
