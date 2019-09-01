defmodule Hibiki.Tag do
  import Ecto.Query

  @type t :: Hibiki.Tag.Schema.t()

  @spec create(String.t(), String.t(), String.t(), Hibiki.Entity.t(), Hibiki.Entity.t()) ::
          {:ok, Hibiki.Tag.t()} | {:error, any}
  def create(name, type, value, creator, scope) do
    %Hibiki.Tag.Schema{creator: creator, scope: scope}
    |> Hibiki.Tag.Schema.changeset(%{name: name, type: type, value: value})
    |> Hibiki.Repo.insert()
  end

  @spec delete(Hibiki.Tag.t()) :: {:ok, Hibiki.Tag.t()} | {:error, any}
  def delete(tag) do
    tag
    |> Hibiki.Repo.delete()
  end

  @spec update(Hibiki.Tag.t(), map) :: {:ok, Hibiki.Tag.t()} | {:error, any}
  def update(tag, changes) do
    tag
    |> Hibiki.Tag.Schema.changeset(changes)
    |> Hibiki.Repo.update()
  end

  @spec get_by_creator(Hibiki.Entity.t()) :: [Hibiki.Tag.t()]
  def get_by_creator(creator) do
    from(t in Hibiki.Tag.Schema,
      where: t.creator_id == ^creator.id
    )
    |> Hibiki.Repo.all()
  end

  @spec get_by_scope(Hibiki.Entity.t()) :: [Hibiki.Tag.t()]
  def get_by_scope(scope) do
    from(t in Hibiki.Tag.Schema,
      where: t.scope_id == ^scope.id
    )
    |> Hibiki.Repo.all()
  end

  @spec by_name(String.t(), Hibiki.Entity.t()) :: Hibiki.Tag.t() | nil
  def by_name(name, scope) do
    from(t in Hibiki.Tag.Schema,
      where: t.scope_id == ^scope.id,
      where: t.name == ^name
    )
    |> Hibiki.Repo.one()
  end

  @spec get_from_tiered_scope(String.t(), Hibiki.Entity.t(), Hibiki.Entity.t()) ::
          Hibiki.Tag.t() | nil
  def get_from_tiered_scope(name, scope, user) do
    scopes = [scope, user, Hibiki.Entity.global()]
    name = String.downcase(name)

    scopes
    |> Enum.dedup()
    |> Enum.reduce(nil, fn sc, acc ->
      acc || Hibiki.Tag.by_name(name, sc)
    end)
  end
end
