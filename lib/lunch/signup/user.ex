defmodule Lunch.Signup.User do
  @moduledoc """
  Represents an user in transition from an anonymous statge to a member state.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @bad_passwords ~w(
    12345678
    password1
    qwertyuiop
    asdfghjk
  )

  schema "users" do
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:username, :string)

    timestamps()
  end

  @doc false
  @spec changeset(__MODULE__.t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_exclusion(
      :password,
      @bad_passwords,
      message: "That password is too common."
    )
    |> validate_length(:password, min: 8)
    |> unique_constraint(:username)
    |> put_pass_hash()
  end

  @doc """
  Helper function to expose blacklisted passwords to tests
  """
  def blacklisted_passwords, do: @bad_passwords

  defp put_pass_hash(%{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset) do
    change(changeset, password: "")
  end
end
