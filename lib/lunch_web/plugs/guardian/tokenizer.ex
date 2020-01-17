defmodule LunchWeb.Guardian.Tokenizer do
  @moduledoc """
  Responsible for managing tokens for Guardian.

  See https://github.com/ueberauth/guardian for more details
  """

  use Guardian, otp_app: :lunch
  alias Lunch.Membership
  alias Lunch.Membership.User

  @spec subject_for_token(%{id: pos_integer} | any, any) ::
          {:ok, String.t()} | {:error, :id_missing_from_subject}
  def subject_for_token(%{id: id}, _) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :id_missing_from_subject}
  end

  @spec resource_from_claims(map) :: {:ok, User.t()} | {:error, :resource_not_found}
  def resource_from_claims(claims) do
    case Membership.get_user(claims["sub"]) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
