defmodule TheLeanCafe.Table do
  use TheLeanCafe.Web, :model
  alias TheLeanCafe.{Table, Repo, Topic}

  schema "tables" do
    has_many :topics, Topic
    field :state, :string, default: "brainstorm"
    field :current_roman_timestamp, :integer, default: 0

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ["state"])
    |> validate_required([])
  end

  def get_by_hashid(table_hashid) do
    TheLeanCafe.Repo.get!(Table, Obfuscator.decode(table_hashid))
  end

  def current_roman_timestamp(id) do
    Repo.all(from t in Table, where: t.id == ^id, select: t.current_roman_timestamp)
    |> Enum.at(0)
  end

  def reset_roman_vote(table) do
    Ecto.Changeset.change(table, %{current_roman_timestamp: :os.system_time(:seconds)})
    |> Repo.update!
  end

  def hashid(%TheLeanCafe.Table{id: id}) do
    Obfuscator.encode(id)
  end

  def topics_query(%Table{id: id, state: "brainstorm"}) do
    Topic.oldest_first_query(id)
  end

  def topics_query(%Table{id: id}) do
    Topic.sorted_by_votes_query(id)
  end

  def current_topic(table) do
    table
    |> topics_query
    |> Topic.incomplete_query
    |> first
  end

end
