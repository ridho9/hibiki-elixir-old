defmodule Hibiki.Tag.Schema do
  use Ecto.Schema

  schema "tag" do
    field(:name, :string)
    field(:type, :string)
    field(:value, :string)

    belongs_to(:creator, Hibiki.Entity.Schema, foreign_key: :creator_id)
    belongs_to(:scope, Hibiki.Entity.Schema, foreign_key: :scope_id)

    timestamps()
  end
end
