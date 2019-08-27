defmodule Hibiki.Tag do
  import Ecto.Query

  def create(name, type, value, creator, scope) do
    %Hibiki.Tag.Schema{creator: creator, scope: scope}
    |> Hibiki.Tag.Schema.changeset(%{name: name, type: type, value: value})
    |> Hibiki.Repo.insert()
  end

  def get_by_creator(creator) do
    from(t in Hibiki.Tag.Schema,
      where: t.creator_id == ^creator.id
    )
    |> Hibiki.Repo.all()
  end

  def get_by_scope(scope) do
    from(t in Hibiki.Tag.Schema,
      where: t.scope_id == ^scope.id
    )
    |> Hibiki.Repo.all()
  end

  def by_name(name, scope) do
    from(t in Hibiki.Tag.Schema,
      where: t.scope_id == ^scope.id,
      where: t.name == ^name
    )
    |> Hibiki.Repo.one()
  end
end
