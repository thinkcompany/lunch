defmodule LunchWeb.Auth.UserController do
  use LunchWeb, :controller

  alias Lunch.Auth
  alias Lunch.Auth.User
  alias LunchWeb.Guardian.Tokenizer.Plug, as: GuardianPlug
  alias Plug.Conn

  @spec new(Conn.t(), any) :: Conn.t()
  def new(conn, _params) do
    changeset = Auth.change_user(%User{})

    conn
    |> GuardianPlug.sign_out()
    |> render("new.html", changeset: changeset)
  end

  @spec create(Conn.t(), map) :: Conn.t() | no_return()
  def create(conn, %{"user" => user_params}) do
    case Auth.authenticate_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User Logged In Successfully."))
        |> GuardianPlug.sign_in(user)
        |> redirect(to: Routes.page_path(conn, :dashboard))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, gettext("Username/Password combination did not exist."))
        |> render("new.html", changeset: changeset)
    end
  end

  @spec delete(Conn.t(), any) :: Conn.t()
  def delete(conn, _) do
    conn
    |> GuardianPlug.sign_out()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
