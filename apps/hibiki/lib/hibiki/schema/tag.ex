defmodule Hibiki.Schema.Tag do
  use Ecto.Schema

  schema "tag" do
    field(:name, :string)
    field(:type, :string)

    field(:creator_id, :string)

    field(:scope_type, :string)
    field(:scope_id, :string)

    timestamps()
  end
end
