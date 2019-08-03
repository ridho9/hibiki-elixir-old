defmodule Hibiki.Schema.Entity do
  use Ecto.Schema

  schema "entities" do
    field(:line_id, :string)
    field(:type, :string)

    has_many(:created_tags, Hibiki.Schema.Tag, foreign_key: :creator_id)
    has_many(:scope_tags, Hibiki.Schema.Tag, foreign_key: :scope_id)
  end

  def global() do
    Hibiki.Repo.get(__MODULE__, 1)
  end
end
