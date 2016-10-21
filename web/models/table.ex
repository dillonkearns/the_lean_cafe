defmodule TheLeanCafe.Table do
  use TheLeanCafe.Web, :model
  alias TheLeanCafe.{Table, Repo}

  schema "tables" do
    has_many :topics, TheLeanCafe.Topic
    field :poll_closed, :boolean, default: false
    field :current_roman_timestamp, :integer, default: 0

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

  def get_by_hashid(table_hashid) do
    TheLeanCafe.Repo.get!(TheLeanCafe.Table, Obfuscator.decode(table_hashid))
  end

  def current_roman_timestamp(id) do
    Repo.all(from t in Table, where: t.id == ^id, select: t.current_roman_timestamp)
    |> Enum.at(0)
  end

  def reset_roman_vote(table) do
    Ecto.Changeset.change(table, %{current_roman_timestamp: :os.system_time(:seconds)})
    |> TheLeanCafe.Repo.update!
  end

  def hashid(%TheLeanCafe.Table{id: id}) do
    Obfuscator.encode(id)
  end
end
