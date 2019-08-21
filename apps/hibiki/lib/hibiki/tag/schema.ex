defmodule Hibiki.Tag.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field(:name, :string)
    field(:type, :string)
    field(:value, :string)

    belongs_to(:creator, Hibiki.Entity.Schema, foreign_key: :creator_id)
    belongs_to(:scope, Hibiki.Entity.Schema, foreign_key: :scope_id)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :type, :value])
    |> validate_required([:name, :type, :value, :creator, :scope])
    |> validate_inclusion(:type, ["image", "text"])
    |> unique_constraint(:name, name: :tags_scope_id_name_index)
  end
end
