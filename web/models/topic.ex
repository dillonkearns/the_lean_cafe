defmodule TheLeanCafe.Topic do
  use TheLeanCafe.Web, :model
  alias TheLeanCafe.{Repo, Topic, DotVote}

  schema "topics" do
    field :name, :string
    has_many :dot_votes, TheLeanCafe.DotVote
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

  def dot_vote_count(topic_id) do
    topic = TheLeanCafe.Repo.get(TheLeanCafe.Topic, topic_id) |> TheLeanCafe.Repo.preload(:dot_votes)
    length(topic.dot_votes)
  end

  def vote_for!(%Topic{id: id}) do
    Repo.insert!(%DotVote{topic_id: id})
  end

  def with_vote_counts(table_id) do
    query = from t in TheLeanCafe.Topic,
      where: t.table_id == ^table_id,
      order_by: t.id,
      left_join: d in assoc(t, :dot_votes),
      select: {t, count(d.id)},
      group_by: t.id
    TheLeanCafe.Repo.all(query)
  end
end
