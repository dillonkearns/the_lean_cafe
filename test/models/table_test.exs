defmodule TheLeanCafe.TableTest do
  use TheLeanCafe.ModelCase

  alias TheLeanCafe.Table

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Table.changeset(%Table{}, @valid_attrs)
    assert changeset.valid?
  end

end
