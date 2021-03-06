defmodule TheLeanCafe.Topic do
  use TheLeanCafe.Web, :model
  alias TheLeanCafe.{Topic, DotVote}

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

  def vote_for(topic_id) do
    %DotVote{topic_id: topic_id}
  end

  def complete(topic) do
    topic
    |> Ecto.Changeset.change(%{completed: true})
  end

  def oldest_first_query(table_id) do
    base_query(table_id)
    |> oldest_first
  end

  def oldest_first(query) do
    query
    |> order_by([topic, dv], [asc: topic.id])
  end

  def with_vote_counts(query) do
    query
    |> select([topic, dv], {topic, count(dv.id)})
  end

  def base_query(table_id) do
    from(topic in Topic, left_join: dv in assoc(topic, :dot_votes), group_by: topic.id)
    |> where([topic], topic.table_id == ^table_id)
  end

  def incomplete_query(query) do
    query
    |> where([topic], topic.completed != true)
  end

  def sorted_by_votes_query(table_id) do
    table_id
      |> base_query
      |> order_by([topic, dv], [desc: count(dv.id)])
      |> oldest_first
  end

end
