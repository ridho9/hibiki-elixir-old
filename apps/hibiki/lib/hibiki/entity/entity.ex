defmodule Hibiki.Entity do
  alias Hibiki.Entity.Schema
  alias Hibiki.Repo

  def global() do
    get("global")
  end

  @spec get(binary) :: struct | nil
  def get(line_id) do
    Schema
    |> Hibiki.Repo.get_by(line_id: line_id)
  end

  @spec create_or_get(binary, any) :: struct
  def create_or_get(line_id, type) do
    case get(line_id) do
      nil ->
        {:ok, entity} = create(line_id, type)
        entity

      entity ->
        entity
    end
  end

  @spec create(binary, binary | atom) :: {:ok, struct} | {:error, any}
  def create(line_id, type) when is_atom(type) do
    create(line_id, "#{type}")
  end

  def create(line_id, type) do
    %Schema{}
    |> Schema.changeset(%{line_id: line_id, type: type})
    |> Repo.insert()
  end

  @spec admin?(struct) :: boolean
  def admin?(entity) do
    entity.line_id in Application.get_env(:hibiki, :admin_id)
  end
end
