initializeMultipleSelect2 = ->
    if $.fn.select2?
        $('.multiple-select2').select2({
            width: '100%',
            placeholder: 'Choose options',
            allowClear: true,
            multiple: true
        })
    else
        console.error('Select2 library is not loaded.')

$(document).ready initializeMultipleSelect2
$(document).on 'turbolinks:load', initializeMultipleSelect2