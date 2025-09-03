userId = $('#current_user_id').val()

if userId?
    App.chatNotification = App.cable.subscriptions.create { channel: "ChatNotificationChannel", user_id: userId },
        connected: ->
            # Called when the subscription is ready for use on the server
            console.log "Connected to ChatNotificationChannel for user: #{userId}"

        disconnected: ->
            # Called when the subscription has been terminated by the server
            console.log "Disconnected from ChatNotificationChannel for user: #{userId}"

        received: (data) ->
            console.log "Received notification data:", data
            notificationDiv = $('#chat-notification')
            if notificationDiv.length
                notificationDiv.fadeIn()
            else
                console.warn "chat-notification div not found"

        send_notification: (title, message) ->
            console.log "Sending notification:", title, message
            #@perform 'send_notification', title: title, message: message