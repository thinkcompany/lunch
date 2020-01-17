defmodule LunchWeb.Router do
  use LunchWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :guardian do
    plug(LunchWeb.Guardian.Plug)
    plug(LunchWeb.Guardian.CurrentUserPlug)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LunchWeb do
    pipe_through([:browser, :guardian, :ensure_auth])

    resources("/profile", ProfileController, only: [:edit, :update], singleton: true)
    resources("/members", ProfileController, only: [:index, :show])
    get("/dashboard", PageController, :dashboard)

    resources("/groups", Membership.OrganizationController,
      only: [:new, :create],
      as: :membership_organization
    )

    resources "/o", OrganizationController, only: [:show] do
      resources "/invitation", InvitationController, only: [:new, :create, :delete]
      get("/invitation/:id", InvitationController, :update, as: :invite_user)

      get("/change_membership/:profile_id", Membership.Organization.ProfileController, :update,
        as: :role_change
      )
    end
  end

  scope "/", LunchWeb do
    # Use the default browser stack
    pipe_through([:browser, :guardian])

    get("/", PageController, :index)
  end

  scope "/signup", LunchWeb.Signup, as: :signup do
    pipe_through([:browser, :guardian])

    resources("/", UserController, only: [:new, :create])
  end

  scope "/", LunchWeb.Auth, as: :auth do
    pipe_through([:browser, :guardian, :ensure_auth])
    post("/logout", UserController, :delete)
  end

  scope "/auth", LunchWeb.Auth, as: :auth do
    pipe_through([:browser, :guardian])

    resources("/", UserController, only: [:new, :create])
  end

  # Other scopes may use custom stacks.
  # scope "/api", LunchWeb do
  #   pipe_through :api
  # end
end
