defmodule LunchWeb.Signup.UserController do
  use LunchWeb, :controller

  alias Lunch.Membership
  alias Lunch.Signup
  alias Lunch.Signup.User
  alias LunchWeb.Guardian.Tokenizer.Plug, as: GuardianPlug
  alias Plug.Conn

  @spec new(Conn.t(), any) :: Conn.t()
  def new(conn, _params) do
    changeset = Signup.change_user(%User{})

    conn
    |> GuardianPlug.sign_out()
    |> render("new.html", changeset: changeset)
  end

  @spec create(Conn.t(), map) :: Conn.t() | no_return()
  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Signup.create_user(user_params),
         _ <- Membership.change_profile(user) do
      conn
      |> put_flash(:info, gettext("User created successfully."))
      |> GuardianPlug.sign_in(user)
      |> redirect(to: Routes.page_path(conn, :dashboard))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
