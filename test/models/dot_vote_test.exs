defmodule TheLeanCafe.DotVoteTest do
  use TheLeanCafe.ModelCase

  alias TheLeanCafe.DotVote

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DotVote.changeset(%DotVote{}, @valid_attrs)
    assert changeset.valid?
  end

end
