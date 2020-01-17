defmodule LunchWeb.ProfileController do
  use LunchWeb, :controller

  alias Lunch.Membership
  alias Lunch.Membership.User
  alias Plug.Conn

  @spec edit(Conn.t(), any) :: Conn.t()
  def edit(conn, _params) do
    render(conn, "edit.html",
      profile: conn |> current_user() |> Map.get(:profile),
      changeset: conn |> current_user() |> Membership.change_profile()
    )
  end

  @spec update(Conn.t(), map) :: Conn.t() | no_return()
  def update(conn, %{"profile" => params}) do
    case conn |> current_user() |> Membership.update_profile(params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: Routes.page_path(conn, :dashboard))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  @spec current_user(Conn.t()) :: User.t()
  defp current_user(conn), do: conn.assigns.current_user
end
