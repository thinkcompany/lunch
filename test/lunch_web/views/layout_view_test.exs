defmodule LunchWeb.LayoutViewTest do
  use LunchWeb.ConnCase, async: true
  alias LunchWeb.LayoutView
  alias Plug.Conn

  test "logo_link/1 returns an index url with no current user", %{conn: conn} do
    conn
    |> Conn.assign(:current_user, nil)
    |> LayoutView.logo_link()
    |> Kernel.==("/")
    |> assert()
  end

  test "logo_link/1 returns an index url with a non-nil current user", %{conn: conn} do
    conn
    |> Conn.assign(:current_user, "any non nil value")
    |> LayoutView.logo_link()
    |> Kernel.==("/dashboard")
    |> assert()
  end
end
