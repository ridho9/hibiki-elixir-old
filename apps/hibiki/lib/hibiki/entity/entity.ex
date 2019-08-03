defmodule Hibiki.Entity do
  alias Hibiki.Entity.Schema

  def global() do
    Hibiki.Repo.get(Schema, 1)
  end
end
