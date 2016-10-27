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
    %{topic | dot_votes: build_list(n, :dot_vote)}
  end
end
