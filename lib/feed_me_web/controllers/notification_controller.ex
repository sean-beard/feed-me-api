defmodule FeedMeWeb.NotificationController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent.Notification
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug(FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer")

  def get_vapid_public_key(conn, _params) do
    public_key = Application.get_env(:web_push_encryption, :vapid_details)[:public_key]

    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, key: public_key}))
  end

  def save_notification_subscription(conn, %{"subscription" => subscription, "origin" => origin}) do
    valid_subscription = Notification.get_valid_subscription(subscription)

    user = conn.assigns.user

    notification_sub = %{
      endpoint: valid_subscription.endpoint,
      auth: valid_subscription.keys.auth,
      p256dh: valid_subscription.keys.p256dh,
      expiration_time: valid_subscription.expiration_time,
      user_id: user.id,
      origin: origin
    }

    case Notification.create_notification_subscription(user, notification_sub) do
      {:ok, _sub} ->
        Conn.send_resp(conn, :ok, Jason.encode!(%{status: 201}))

      {:error, _sub_changeset} ->
        IO.puts("Error creating new notification subscription from #{subscription}")

        Conn.send_resp(
          conn,
          :internal_server_error,
          Jason.encode!(%{status: 500, message: "Error creating notification subscription"})
        )
    end
  end
end
