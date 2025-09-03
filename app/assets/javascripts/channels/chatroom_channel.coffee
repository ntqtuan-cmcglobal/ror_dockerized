chatRoomId = $('#chat_room_id').val()

if chatRoomId?
    App.chatroom = App.cable.subscriptions.create { channel: "ChatroomChannel", chat_room_id: chatRoomId },
        connected: ->
            # Called when the subscription is ready for use on the server
            console.log "Connected to ChatroomChannel: #{chatRoomId}"

        disconnected: ->
            # Called when the subscription has been terminated by the server
            console.log "Disconnected from ChatroomChannel: #{chatRoomId}"

        received: (data) ->
            console.log "Received data:", data
            # Called when there's incoming data on the websocket for this channel
            isCurrentUser = data['sender_id'] == parseInt($('#current_user_id').val())
            rowClass = if isCurrentUser then 'flex-row' else 'flex-row-reverse'
            bgClass = if isCurrentUser then 'bg-green-100 text-green-900' else 'bg-blue-100 text-blue-900'
            timeAlign = if isCurrentUser then 'text-left' else 'text-right'

            redDot = unless isCurrentUser then '<span class="ml-2 inline-block w-2 h-2 rounded-full bg-red-500" title="New message"></span>' else ''
            $('#messages').append """
                <div class="flex items-start gap-3 #{rowClass}">
                    <div>
                        <div class="#{bgClass} rounded-lg px-4 py-2 flex items-center">
                            <span class="font-semibold mr-1">#{data['user_full_name']}:</span> #{data['message']}
                            #{redDot}
                        </div>
                        <div class="text-xs text-gray-400 mt-1 #{timeAlign}">#{data['formatted_time']}</div>
                    </div>
                </div>
            """
            if $('#messages').length > 0
                $('#messages').scrollTop($('#messages')[0].scrollHeight)

        send_message: (message) ->
            console.log "Sending message:", message
            #@perform 'send_message', message: message