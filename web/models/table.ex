defmodule TheLeanCafe.Table do
  use TheLeanCafe.Web, :model

  schema "tables" do
    has_many :topics, TheLeanCafe.Topic

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
