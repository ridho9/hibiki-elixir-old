defmodule Hibiki.Command.Upload do
  def upload_base64_to_catbox(string) do
    with {:ok, path} <- Temp.path(),
         {:ok, binary} <- Base.decode64(string),
         :ok <- File.write(path, binary),
         {:ok, mime} <- mime_file(path),
         [ext] = :mimerl.mime_to_exts(mime) do
      file =
        {:file, path,
         {"form-data", [name: "fileToUpload", filename: Path.basename(path) <> ".#{ext}"]}, []}

      data = {:multipart, [file, {"reqtype", "fileupload"}, {"userhash", ""}]}
      url = "https://catbox.moe/user/api.php"

      result = HTTPoison.post(url, data)
      File.rm(path)

      case result do
        {:ok, %HTTPoison.Response{body: link}} ->
          {:ok, link}

        err ->
          err
      end
    end
  end

  defp mime_file(path) do
    with {filetype, 0} <- System.cmd("file", [path, "--mime-type"]),
         mime = String.slice(filetype, (String.length(path) + 2)..-2) do
      {:ok, mime}
    end
  end
end
