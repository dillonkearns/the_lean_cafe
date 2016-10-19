defmodule TheLeanCafe.Table do
  use TheLeanCafe.Web, :model

  schema "tables" do
    has_many :topics, TheLeanCafe.Topic
    field :poll_closed, :boolean, default: false

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

  def hashid(%TheLeanCafe.Table{id: id}) do
    Obfuscator.encode(id)
  end
end
