defmodule Hibiki.Entity.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entities" do
    field(:line_id, :string)
    field(:type, :string)

    has_many(:created_tags, Hibiki.Tag.Schema, foreign_key: :creator_id)
    has_many(:scope_tags, Hibiki.Tag.Schema, foreign_key: :scope_id)
  end

  @type t :: %__MODULE__{
          line_id: String.t(),
          type: String.t(),
          created_tags: [Hibiki.Tag.t()],
          scope_tags: [Hibiki.Tag.t()]
        }

  def changeset(struct, params) do
    struct
    |> cast(params, [:line_id, :type])
    |> validate_required([:line_id, :type])
    |> validate_inclusion(:type, ["global", "user", "group", "room"])
    |> unique_constraint(:line_id, name: :entities_line_id_index)
  end
end
