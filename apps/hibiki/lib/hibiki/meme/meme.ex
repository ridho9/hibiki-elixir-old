defmodule Hibiki.Meme do
  @username Application.get_env(:hibiki, :imgflip_username)
  @password Application.get_env(:hibiki, :imgflip_password)

  def generate(meme_id, text0, text1) do
    body =
      {:form,
       [
         template_id: meme_id,
         username: @username,
         password: @password,
         text0: text0,
         text1: text1
       ]}

    with {:ok, %HTTPoison.Response{body: response}} <-
           HTTPoison.post("https://api.imgflip.com/caption_image", body, []),
         {:ok, result} <- Jason.decode(response) do
      handle_result(result)
    end
  end

  def handle_result(%{"success" => true, "data" => %{"url" => url}}) do
    {:ok, url}
  end

  def handle_result(%{"success" => false, "error_message" => err}) do
    {:error, err}
  end
end
