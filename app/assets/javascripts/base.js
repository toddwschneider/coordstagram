$(function() {
  var $modal = $('#gram-modal')

  var renderItemInModal = function($item) {
    $('.instagram-item.selected').removeClass('selected')
    $item.addClass('selected')
    var $data = $item.find('.modal-item-content')

    var igHref = 'http://instagram.com/' + $data.data('username')

    var $avatar = $('<a>').attr('href', igHref).
                           attr('target', '_blank').
                           append($('<img>').attr('src', $data.data('profile')).
                                             attr('class', 'avatar'))

    var user = '<a href="' + igHref + '" target="_blank">' +
               $data.data('username') + '</a>'

    var $timestamp = $('<span>').attr('class', 'ts ago').
                                 attr('data-iso', $data.data('created-time'))

    var $dateLink = $('<a>').attr('href', $data.data('link')).
                             attr('target', '_blank').
                             append($timestamp)

    var $meta = $('<div>').append($dateLink)

    var loc = $data.find('.ig-location').text()
    if (loc.length) {
      $meta.append('<span class="sep">•</span>').
            append('<span class="loc">' + loc + '</span>')
    }

    var caption = $data.find('.ig-caption').html()
    var filter = 'Taken with ' + $data.data('filter') + ' filter'

    var mediaContent
    if ($data.data('ig-type') === 'video') {
      mediaContent = '<video controls autoplay poster="' + $data.data('full-res-img') + '">' +
                     '<source src="' + $data.data('full-res-vid') + '" type="video/mp4">' +
                     "Sorry, your browser doesn't support video" +
                     '</source></video>'
    } else {
      mediaContent = '<img src="' + $data.data('full-res-img') + '">'
    }

    $modal.find('.ig-media').html(mediaContent)
    $modal.find('.ig-avatar').html($avatar[0].outerHTML)
    $modal.find('.ig-user').html(user)
    $modal.find('.ig-meta').html($meta.html())
    $modal.find('.ig-caption').html(caption)
    $modal.find('.ig-filter').html(filter)

    $('video').mediaelementplayer()
    updateTimestamps()
    replacePath($data.data('path'))
    drawMediaMap($data.data('lat'), $data.data('long'))
  }

  $modal.on('shown.bs.modal', function(e) {
    renderItemInModal($(e.relatedTarget))
  })

  $modal.on('hide.bs.modal', function() {
    replacePath('/')
  })

  $(document).keydown(function(e) {
    if (!$modal.hasClass('in')) return

    if (e.keyCode === 37) {
      openPrevItem()
    } else if (e.keyCode === 39) {
      openNextItem()
    } else if (e.keyCode === 13) {
      $modal.find('video').click()
      return
    }
  })

  var openNextItem = function() {
    var $item = $('.instagram-item.selected').next()
    if ($item.length) {
      renderItemInModal($item)
    } else {
      loadNextPage()
    }
  }

  var openPrevItem = function() {
    var $item = $('.instagram-item.selected').prev()
    if ($item.length) renderItemInModal($item)
  }

  $modal.on('click', '.prev-item, .prev-item-mobile', function() {
    openPrevItem()
  })

  $modal.on('click', '.next-item, .next-item-mobile', function() {
    openNextItem()
  })

  $('.instagram-items').on('click', '.ig-link', function(e) {
    e.preventDefault()
  })

  $(document).on('click', '.pagination > .next-page', function(e) {
    e.preventDefault()

    $(this).parent().addClass('loading')

    $.get(this.href, function(data) {
      var $data = $(data)

      $('.instagram-items').append($data.find('.instagram-item'))
      $('.pagination').replaceWith($data.filter('.pagination'))
    })
  })

  var loadNextPage = function() {
    var $pagination = $('.pagination')

    if (!$pagination.hasClass('loading')) {
      $pagination.find('.next-page').click()
    }
  }

  $(window).scroll(function() {
    if ($(window).scrollTop() > $(document).height() - $(window).height() - 300) {
      loadNextPage()
    }
  })

  var updateTimestamps = function() {
    var now = moment()

    $('.ts.ago').each(function(i, e) {
      var $this = $(e)
      var eventMoment = moment($this.data('iso'))
      var time = eventMoment.fromNow()

      $this.removeClass('ago').html(time)
    })
  }

  var replacePath = function(path) {
    if (window.history && window.history.replaceState) {
      window.history.replaceState({}, '', path)
    }
  }

  var drawOverviewMap = function() {
    var $container = $('#overview-map')
    if (!$container.length || !$container.is(':empty')) return

    var overviewMap = L.map('overview-map').setView([LATITUDE, LONGITUDE], initialZoom)
    tileLayer().addTo(overviewMap)
    circle().addTo(overviewMap)
  }

  var drawMediaMap = function(centerLat, centerLong) {
    mediaMap.setView([centerLat, centerLong], initialZoom)
    marker.setLatLng([centerLat, centerLong])
  }

  var mediaMap = L.map('ig-map')

  var l = Math.ceil(Math.log(MAX_DISTANCE_IN_METERS / 125) / Math.log(2))
  var initialZoom = Math.max(Math.min(17 - l, 17), 11)

  var tileLayer = function() {
    return L.tileLayer('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'
    })
  }

  var circle = function() {
    return L.circle([LATITUDE, LONGITUDE], MAX_DISTANCE_IN_METERS, {
      color: '#f00',
      fillColor: '#f03',
      fillOpacity: 0.1,
      weight: 2
    })
  }

  tileLayer().addTo(mediaMap)
  circle().addTo(mediaMap)
  var marker = L.marker([LATITUDE, LONGITUDE]).addTo(mediaMap)

  var $standaloneItem = $('.standalone-item')
  if ($standaloneItem.length) {
    $modal.show()
    renderItemInModal($standaloneItem)
  }

  $('#map-modal').on('shown.bs.modal', function() {
    drawOverviewMap()
  })
})

function handleBrokenImage(img) {
  $(img).closest('.instagram-item').remove()
}
