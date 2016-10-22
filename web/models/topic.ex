defmodule TheLeanCafe.Topic do
  use TheLeanCafe.Web, :model
  alias TheLeanCafe.{Repo, Topic, DotVote}

  schema "topics" do
    field :name, :string
    field :completed, :boolean
    has_many :dot_votes, TheLeanCafe.DotVote
    belongs_to :table, TheLeanCafe.Table

    timestamps()
  end

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

  def vote_counts_query(table_id) do
    from t in TheLeanCafe.Topic,
      where: t.table_id == ^table_id,
      order_by: t.id,
      left_join: d in assoc(t, :dot_votes),
      select: {t, count(d.id)},
      group_by: t.id
  end

  def with_vote_counts(table_id) do
    TheLeanCafe.Repo.all(vote_counts_query(table_id))
  end

  def sorted_with_vote_counts(table_id) do
    TheLeanCafe.Repo.all(vote_counts_query(table_id))
    |> Enum.sort_by(&(elem(&1, 1)))
    |> Enum.reverse
  end

end
