defmodule Lunch.Auth.User do
  @moduledoc """
  Represents an user in transition from an anonymous state to an authenticated
  state.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "users" do
    field(:password_hash, :string)
    field(:username, :string)

    timestamps()
  end

  @doc false
  @spec changeset(__MODULE__.t() | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password_hash])
    |> validate_required([:username, :password_hash])
  end
end
