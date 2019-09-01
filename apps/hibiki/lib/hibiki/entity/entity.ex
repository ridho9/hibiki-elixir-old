defmodule Hibiki.Entity do
  alias Hibiki.Entity.Schema
  alias Hibiki.Repo

  @type t :: Hibiki.Entity.Schema.t()

  def global() do
    get("global")
  end

  @spec get(String.t()) :: t | nil
  def get(line_id) do
    Schema
    |> Repo.get_by(line_id: line_id)
  end

  @spec create_or_get(String.t(), String.t()) :: t
  def create_or_get(line_id, type) do
    case get(line_id) do
      nil ->
        {:ok, entity} = create(line_id, type)
        entity

      entity ->
        entity
    end
  end

  @spec create(String.t(), String.t()) :: {:ok, t} | {:error, any}
  def create(line_id, type) when is_atom(type) do
    create(line_id, "#{type}")
  end

  def create(line_id, type) do
    %Schema{}
    |> Schema.changeset(%{line_id: line_id, type: type})
    |> Repo.insert()
  end

  @spec admin?(t) :: boolean
  def admin?(entity) do
    entity.line_id in Application.get_env(:hibiki, :admin_id)
  end
end
