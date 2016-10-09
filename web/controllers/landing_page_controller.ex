defmodule TheLeanCafe.LandingPageController do
  use TheLeanCafe.Web, :controller

  alias TheLeanCafe.LandingPage

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
