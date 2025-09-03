class MessagesController < ApplicationController
  before_action :authenticate_user!
  def index
    @chat_users = case current_user.role
                  when 'buyer'
                    User.where(role: %w[sellers admin])
                  when 'seller'
                    User.where(role: 'admin')
                  when 'admin'
                    User.where.not(id: current_user.id)
                  else
                    User.none
                  end
    first_chat_user = @chat_users.first
    if first_chat_user
      @chat_room_id = ChatRoom.find_or_create_by_user_ids([current_user.id,
                                                           first_chat_user.id]).chat_room_id

      @messages = Message.where(chat_room_id: @chat_room_id)
    end
    render index: @messages
  end

  def show
    @message = Message.find(params[:id])
    render json: @message
  end

  def create
    @message = current_user.messages.build(message_params)
    if @message.save
      ActionCable.server.broadcast "chatroom_channel_#{@message.chat_room_id}",
                                   { message: @message.content,
                                     sender_id: @message.user_id,
                                     user_full_name: @message.user.full_name,
                                     formatted_time: @message.created_at.strftime('%I:%M %p') }
      pp ActionCable.server.connections
    else
      render :index
    end
  end

  def update
    @message = Message.find(params[:id])
    if @message.update(message_params)
      render json: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    head :no_content
  end

  def switch_user
    @selected_user_id = params[:user_id]
    return unless @selected_user_id

    @chat_room_id = ChatRoom.find_or_create_by_user_ids([current_user.id, @selected_user_id]).chat_room_id
    @messages = Message.where(chat_room_id: @chat_room_id)
    @chat_users = case current_user.role
                  when 'buyer'
                    User.where(role: %w[sellers admin])
                  when 'seller'
                    User.where(role: 'admin')
                  when 'admin'
                    User.where.not(id: current_user.id)
                  else
                    User.none
                  end

    render :index
  end

  private

  def message_params
    params.require(:message).permit(:content, :chat_room_id)
  end
end
