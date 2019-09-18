defmodule Hibiki.Sauce.Command do
  use Hibiki.Command
  alias Hibiki.Command.Options
  alias Hibiki.Upload
  alias Hibiki.Sauce

  def name, do: "sauce"

  def description, do: "Bruh I need sauce"

  def pre_handle(args, ctx) do
    scope = Hibiki.Entity.scope_from_context(ctx)

    args = args |> Map.put("scope", scope)

    {:ok, args, ctx}
  end

  def options,
    do:
      %Options{allow_empty_last: true}
      |> Options.add_named("url", "image url, can be empty to use last sent image")

  def handle(%{"scope" => scope, "url" => ""} = args, ctx) do
    case Hibiki.Entity.Data.get(scope, :last_image_id) do
      nil ->
        ctx
        |> add_error("Please send an image first")
        |> send_reply()

      image_id ->
        provider = Upload.Provider.Catbox

        case Upload.upload_from_image_id(provider, image_id, ctx.client) do
          {:ok, image_url} ->
            args = %{args | "url" => image_url}
            handle(args, ctx)

          {:error, err} ->
            ctx
            |> add_error(err)
            |> send_reply()
        end
    end
  end

  def handle(%{"url" => url}, ctx) do
    res = url |> Sauce.sauce_all_provider() |> Enum.map(fn x -> "> #{x}" end) |> Enum.join("\n")
    res = "May the sauce be with you: \n" <> res

    ctx
    |> add_text_message(res)
    |> send_reply()
  end
end
