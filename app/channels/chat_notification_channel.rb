class ChatNotificationChannel < ApplicationCable::Channel
  def subscribed
    user_id = params[:user_id]
    return unless user_id

    stream_from "chat_notification_channel_#{user_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
