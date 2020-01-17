defmodule LunchWeb.LayoutView do
  use LunchWeb, :view

  @spec logo_link(Plug.Conn.t()) :: String.t()
  def logo_link(%{assigns: %{current_user: nil}} = conn) do
    Routes.page_path(conn, :index)
  end

  def logo_link(conn) do
    Routes.page_path(conn, :dashboard)
  end
end
