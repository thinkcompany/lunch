defmodule LunchWeb.PageController do
  use LunchWeb, :controller
  alias Plug.Conn

  @spec index(Conn.t(), any) :: Conn.t()
  def index(conn, _params) do
    render(conn, "index.html")
  end

  @spec dashboard(Conn.t(), any) :: Conn.t()
  def dashboard(conn, _params) do
    render(conn, "dashboard.html")
  end
end
