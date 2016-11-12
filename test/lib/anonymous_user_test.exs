defmodule TheLeanCafe.AnonymousUserTest do

  use ExUnit.Case
  alias TheLeanCafe.AnonymousUser

  test "generates name based on no other users" do
    online_users = []
    assert %{username: "Anonymoose"} = AnonymousUser.generate(online_users)
  end

  test "doesn't repeat usernames that are already online" do
    online_usernames = ["Anonymoose"]
    assert %{username: "Anonymous Panda"} = AnonymousUser.generate(online_usernames)
  end

  test "2 anonymous usernames taken" do
    online_usernames = ["Anonymoose", "Anonymous Panda"]
    assert %{username: "Anonymoise Tortoise"} = AnonymousUser.generate(online_usernames)
  end

  test "anonymous and public users present" do
    online_usernames = ["Anonymoose", "John Smith", "Anonymous Panda"]
    assert %{username: "Anonymoise Tortoise"} = AnonymousUser.generate(online_usernames)
  end

end
