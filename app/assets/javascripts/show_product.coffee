for eventName in ["DOMContentLoaded", "turbolinks:load"]
    document.addEventListener eventName, ->
        stars = document.querySelectorAll '#star-rating .star-label'
        stars.forEach (star) ->
            star.addEventListener 'click', (e) ->
                selected = parseInt(star.dataset.star)
                document.getElementById("review_rating_#{selected}").checked = true
                stars.forEach (s) ->
                    svg = s.querySelector('svg')
                    if parseInt(s.dataset.star) <= selected
                        svg.setAttribute 'fill', '#FBBF24'
                        svg.classList.remove 'opacity-60'
                    else
                        svg.setAttribute 'fill', 'none'
                        svg.classList.add 'opacity-60'
