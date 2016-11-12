defmodule TheLeanCafe.AnonymousUser do

  @users [
    %{username: "Anonymoose", avatar: "https://33.media.tumblr.com/avatar_470dbb0588d8_128.png"},
    %{username: "Anonymous Panda", avatar: "https://67.media.tumblr.com/avatar_b669dca2d6d4_128.png"},
    %{username: "Anonymoise Tortoise", avatar: "https://fuzfeed.com/wp-content/uploads/2014/10/14823-Baby-Hermanns-Tortoise-white-background.jpg"},
  ]

  def generate(online_usernames) do
    username =
      @users |> Enum.find(&(!(&1.username in online_usernames)))
  end

end
