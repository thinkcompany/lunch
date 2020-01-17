defmodule Lunch.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Lunch.Auth.User
  alias Lunch.Repo

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  @spec change_user(User.t()) :: Ecto.Changeset.t()
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @spec authenticate_user(map) :: {:ok | :error, User.t() | Ecto.Changeset.t()}
  def authenticate_user(%{"username" => user, "password" => pass}) do
    authenticate_user(%{username: user, password: pass})
  end

  def authenticate_user(%{username: user, password: pass}) do
    user
    |> fetch_user_by_username()
    |> check_password(pass)
  end

  defp fetch_user_by_username(username) do
    User
    |> where([user], user.username == ^username)
    |> Repo.one()
  end

  defp check_password(%User{} = user, password) do
    password
    |> Bcrypt.verify_pass(user.password_hash)
    |> case do
      true ->
        {:ok, user}

      false ->
        Bcrypt.no_user_verify()
        {:error, change_user(%User{})}
    end
  end

  defp check_password(_, _), do: {:error, change_user(%User{})}
end
