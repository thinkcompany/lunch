defmodule LunchWeb.InvitationView do
  use LunchWeb, :view
  alias Lunch.Membership.Invitation
  alias Plug.Conn

  @spec invitations(Conn.t()) :: list(Invitation.t())
  def invitations(%{assigns: %{current_user_invitations: invites}}), do: invites

  def invitations(_), do: []
end
