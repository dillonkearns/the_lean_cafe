defmodule TheLeanCafe.AnonymousAnimal do

  @users [
    %{username: "Anonymous Bear", avatar: "/images/bear.jpg"},
    %{username: "Anonymous Fox", avatar: "/images/fox.jpg"},
    %{username: "Anonymous Lemur", avatar: "/images/lemur.jpg"},
    %{username: "Anonymous Dog", avatar: "/images/dog.jpg"},
    %{username: "Anonymous Goat", avatar: "/images/goat.jpg"},
    %{username: "Anonymous Lion", avatar: "/images/lion.jpg"},
    %{username: "Anonymous Alpaca", avatar: "/images/alpaca.jpg"},
    %{username: "Anonymous Cow", avatar: "/images/cow.jpg"},
    %{username: "Anonymous Hipster Panda", avatar: "/images/hipster-panda.jpg"},
    %{username: "Anonymous Owl", avatar: "/images/owl.jpg"},
    %{username: "Anonymous Ape", avatar: "/images/monkey.png"},
  ]

  def generate(online_usernames) do
    Enum.find(@users, &(!(&1.username in online_usernames)))
  end

end
