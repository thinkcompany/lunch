defmodule LunchWeb.OrganizationController do
  use LunchWeb, :controller
  alias Plug.Conn

  plug LunchWeb.CurrentOrganizationPlug
  plug LunchWeb.EnsureUserAuthorizedPlug

  @spec show(Conn.t(), map) :: Conn.t()
  def show(conn, _) do
    render(conn, "show.html", org: conn.assigns.current_organization)
  end
end
