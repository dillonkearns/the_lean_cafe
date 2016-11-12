defmodule TheLeanCafe.AnonymousAnimalTest do

  use ExUnit.Case
  alias TheLeanCafe.AnonymousAnimal

  test "generates name based on no other users" do
    online_users = []
    assert %{username: "Anonymous Bear"} = AnonymousAnimal.generate(online_users)
  end

  test "doesn't repeat usernames that are already online" do
    online_usernames = ["Anonymous Bear"]
    assert %{username: "Anonymous Fox"} = AnonymousAnimal.generate(online_usernames)
  end

  test "2 anonymous usernames taken" do
    online_usernames = ["Anonymous Bear", "Anonymous Fox"]
    assert %{username: "Anonymous Lemur"} = AnonymousAnimal.generate(online_usernames)
  end

  test "anonymous and public users present" do
    online_usernames = ["Anonymous Bear", "John Smith", "Anonymous Fox"]
    assert %{username: "Anonymous Lemur"} = AnonymousAnimal.generate(online_usernames)
  end

end
