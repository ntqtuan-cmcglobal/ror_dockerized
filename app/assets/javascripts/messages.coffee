$ ->
    $('#send_message_button').on 'click', (e) ->
        $button = $(this)
        $form = $button.closest('form')
        $input = $form.find('input[name="message[content]"]')
        $button.prop('disabled', true)
        $.ajax
            url: $form.attr('action')
            method: $form.attr('method')
            data: $form.serialize()
            success: ->
                $input.val('')
            complete: ->
                $button.prop('disabled', false)
        e.preventDefault()

    $('#user_select').on 'change', ->
            $('#user_switch_form').submit()

    if $('#messages').length > 0
        $('#messages').scrollTop($('#messages')[0].scrollHeight)