defmodule FeedMeWeb.Router do
  use FeedMeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug CORSPlug, origin: "*"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", FeedMeWeb do
    pipe_through :browser

    # this line has to be before the subsequent line or else `:provider` matches `logout`
    get "/logout", AuthController, :logout
    # :request is defined via Ueberauth package
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/", FeedMeWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/subscription", SubscriptionController, :index
    post "/subscription", SubscriptionController, :subscribe
    delete "/subscription", SubscriptionController, :unsubscribe
    options "/subscription", SubscriptionController, :nothing

    get "/feed", FeedController, :index
    options "/feed", FeedController, :nothing

    post "/item", FeedController, :update_item_status
    options "/item", FeedController, :nothing

    get "/item/:id", FeedController, :get_item
    options "/item/:id", FeedController, :nothing
  end

  # Other scopes may use custom stacks.
  # scope "/api", FeedMeWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FeedMeWeb.Telemetry
    end
  end
end
