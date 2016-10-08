defmodule TheLeanCafe.Router do
  use TheLeanCafe.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TheLeanCafe do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/tables", TableController, param: "hashid"
  end

  # Other scopes may use custom stacks.
  # scope "/api", TheLeanCafe do
  #   pipe_through :api
  # end
end
