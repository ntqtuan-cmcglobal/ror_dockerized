class ChatroomChannel < ApplicationCable::Channel
  def subscribed
    chat_room_id = params[:chat_room_id]
    return unless chat_room_id

    stream_from "chatroom_channel_#{chat_room_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
