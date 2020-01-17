defmodule LunchWeb.AuthHelper do
  @moduledoc """
  Methods for plucking common data out of assigns
  """

  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Plug.Conn

  @spec current_user_admin?(Conn.t()) :: boolean
  def current_user_admin?(%{assigns: %{current_user_is_admin: x}}), do: x
  def current_user_admin?(_), do: false

  @spec authenticated?(Conn.t()) :: boolean
  def authenticated?(%{assigns: %{current_user: %User{}}}), do: true
  def authenticated?(_), do: false

  @spec current_profile(Conn.t()) :: Profile.t() | nil
  def current_profile(%{assigns: %{current_user: %User{profile: profile}}}), do: profile
  def current_profile(_), do: nil

  @spec current_user(Conn.t()) :: User | nil
  def current_user(%{assigns: %{current_user: user}}), do: user
  def current_user(_), do: nil
end
