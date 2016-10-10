defmodule TheLeanCafe.DotVote do
  use TheLeanCafe.Web, :model

  schema "dot_votes" do
    belongs_to :topic, TheLeanCafe.Topic

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
