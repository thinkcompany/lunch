defmodule LunchWeb.PageController do
  use LunchWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
