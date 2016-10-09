defmodule TheLeanCafe.Topic do
  use TheLeanCafe.Web, :model

  schema "topics" do
    field :name, :string
    belongs_to :table, TheLeanCafe.Table

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
