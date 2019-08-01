defmodule Hibiki.Schema.Tag do
  use Ecto.Schema

  schema "tag" do
    field(:name, :string)
    field(:type, :string)
    field(:value, :string)

    belongs_to(:creator, Hibiki.Schema.Entity, foreign_key: :creator_id)
    belongs_to(:scope, Hibiki.Schema.Entity, foreign_key: :scope_id)

    timestamps()
  end
end
