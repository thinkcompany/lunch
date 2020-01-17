defmodule LunchWeb.Guardian.CurrentUserPlug do
  @moduledoc """
  Plug that populates the current_user assigns
  """

  alias Lunch.Membership
  alias LunchWeb.Guardian.Tokenizer.Plug, as: GuardianPlug
  alias Plug.Conn

  @spec init(any) :: any
  def init(opts), do: opts

  @spec call(Conn.t(), any) :: Conn.t()
  def call(conn, _opts) do
    user = GuardianPlug.current_resource(conn)

    conn
    |> Conn.assign(:current_user, user)
    |> Conn.assign(:current_user_invitations, user_invitations(user))
  end

  defp user_invitations(%{username: username}) do
    Membership.invitations_for(username)
  end

  defp user_invitations(_), do: []
end
