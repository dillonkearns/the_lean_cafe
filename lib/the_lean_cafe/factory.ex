defmodule TheLeanCafe.Factory do
  use ExMachina.Ecto, repo: TheLeanCafe.Repo

  alias TheLeanCafe.{Table, Topic, DotVote}

  def table_factory do
    %Table{}
  end

  def topic_factory do
    %Topic{
      name: sequence(:name, &"Topic #{&1}"),
    }
  end

  def dot_vote_factory do
    %DotVote{}
  end

  def with_dot_votes(topic, n) do
    # build_list(0, ...) mistakenly builds a List with 2 items
    dot_votes = if n == 0 do
      []
    else
      build_list(n, :dot_vote)
    end
    %{topic | dot_votes: dot_votes}
  end
end
