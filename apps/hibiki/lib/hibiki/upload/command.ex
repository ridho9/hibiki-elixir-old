defmodule Hibiki.Upload.Command do
  use Hibiki.Command
  alias Hibiki.Upload
  alias Hibiki.Upload.Provider

  def name, do: "upload"

  def description, do: "Upload last sent image from this scope to catbox"

  def pre_handle(args, ctx) do
    scope = Hibiki.Entity.scope_from_context(ctx)

    args = args |> Map.put("scope", scope)

    {:ok, args, ctx}
  end

  def handle(%{"scope" => scope}, ctx) do
    case Hibiki.Entity.Data.get(scope, :last_image_id) do
      nil ->
        ctx
        |> add_error("Please send an image first")
        |> send_reply()

      image_id ->
        provider = Provider.Catbox
        cache_key = {:uploaded_image, image_id, provider.id}

        case Hibiki.Cache.get(cache_key) do
          nil ->
            with {:ok, image_binary} <- LineSDK.Client.get_content(ctx.client, image_id),
                 {:ok, image_url} <- Upload.upload_binary(provider, image_binary) do
              Hibiki.Cache.set(cache_key, image_url)
              {:ok, image_url}
            end

          image_url ->
            {:ok, image_url}
        end
        |> case do
          {:ok, image_url} ->
            ctx
            |> add_text_message(image_url)
            |> send_reply()

          {:error, err} ->
            ctx
            |> add_error(err)
            |> send_reply()
        end
    end
  end
end
