defmodule Hibiki.Tag do
  alias Hibiki.Tag.Schema
  import Ecto.Query

  def create(name, type, value, creator, scope) do
    name = String.downcase(name)

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
end
