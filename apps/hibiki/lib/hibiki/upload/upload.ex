defmodule Hibiki.Upload do
  alias Hibiki.Upload.Provider.Catbox

  @spec upload_base64_to_catbox(String.t()) :: {:ok, String.t()} | {:error, any}
  def upload_base64_to_catbox(string) do
    with {:ok, binary} <- Base.decode64(string) do
      Catbox.upload_binary(binary)
    end
  end
end
