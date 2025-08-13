#= require select2

$ ->
    # Single select example
    $('.single-select2').select2
        placeholder: 'Select an option'
        allowClear: true

    # Multiple select example
    $('.multiple-select2').select2
        placeholder: 'Select one or more options'
        multiple: true
        allowClear: true