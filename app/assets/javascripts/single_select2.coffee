initSelect2 = ->
    if $.fn.select2?
        $('.single-select2').select2({
            width: '100%',
            placeholder: 'Select an option',
            allowClear: true
        })
    else
        console.error('Select2 library is not loaded.')

$(document).ready initSelect2
$(document).on 'turbolinks:load', initSelect2