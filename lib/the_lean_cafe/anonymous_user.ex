defmodule TheLeanCafe.AnonymousUser do

  @users [
    %{username: "Anonymous Bear", avatar: "http://www.shutterstock.com/blog/wp-content/uploads/sites/5/2014/08/who-nose-grizzly-bear.jpg"},
    %{username: "Anonymous Fox", avatar: "http://farm7.static.flickr.com/6201/6110572699_9c6f3daf39_m.jpg"},
    %{username: "Anonymous Lemur", avatar: "http://lh3.googleusercontent.com/PVEmKOTDDpfwj-3g5j4iHZmsVpHw8ikYkHNxSKgjuPW3lR-QO325UqclV3WE4NmSIV9byjlnU3EaLoiR6wO4mjk=s700"},
    %{username: "Anonymous Dog", avatar: "https://www.outsideonline.com/sites/default/files/styles/thumbnail_medium/public/migrated-images/dogs-happiness-frazier_h.jpg?itok=X8RFNWJx"},
    %{username: "Anonymous Lion", avatar: "http://farm1.static.flickr.com/37/86588271_349e76c782_m.jpg"},
    %{username: "Anonymous Alpaca", avatar: "http://farm9.static.flickr.com/8496/8409506816_555d6c1c09_m.jpg"},
    %{username: "Anonymous Cow", avatar: "https://s-media-cache-ak0.pinimg.com/564x/61/4e/d3/614ed34f4485461b2d1e47b33441f377.jpg"},
    %{username: "Anonymous Ape", avatar: "/images/monkey.png"},
    %{username: "Anonymous Hipster Panda", avatar: "https://67.media.tumblr.com/avatar_b669dca2d6d4_128.png"},
    %{username: "Anonymous Owl", avatar: "http://wfiles.brothersoft.com/o/owl_face_63097-1400x1050.jpg"},
  ]

  def generate(online_usernames) do
    username =
      @users |> Enum.find(&(!(&1.username in online_usernames)))
  end

end
