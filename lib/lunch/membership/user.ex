defmodule Lunch.Membership.User do
  @moduledoc """
  Represents a member
  """
  use Ecto.Schema
  alias Lunch.Membership.Profile

  @type t :: %__MODULE__{}

  schema "users" do
    field(:username, :string)
    has_one(:profile, Profile)

    timestamps()
  end
end
