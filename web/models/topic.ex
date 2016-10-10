defmodule TheLeanCafe.Topic do
  use TheLeanCafe.Web, :model

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
end
