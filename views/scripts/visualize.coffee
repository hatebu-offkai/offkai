margin = 50
width = 700
height = 300
image_scale = 100
draw = (data) ->
  console.log data
  "use strict"
  time_scale = d3.time.scale().range([
    margin
    width - margin
  ]).domain(d3.extent(data.users, (d) ->
    new Date(d.profile.first_bookmark.timestamp)
  ))
  count_scale = d3.scale.log().range([
    height - margin
    margin
  ]).domain(d3.extent(data.users, (d) ->
    d.profile.bookmark_count
  ))
  d3.select(".container").append("svg").attr("width", width).attr "height", height
  d3.select("svg").selectAll("image").data(data.users).enter().append "image"
  d3.selectAll("image").attr
    "xlink:href": (d) ->
      d.icon_n

    width: (d) ->
      100 * (height - margin - count_scale(d.profile.bookmark_count)) / (height - margin)

    height: (d) ->
      100 * (height - margin - count_scale(d.profile.bookmark_count)) / (height - margin)

    x: (d) ->
      time_scale new Date(d.profile.first_bookmark.timestamp)

    y: (d) ->
      count_scale d.profile.bookmark_count

    opacity: 0.5

  d3.select("svg").append("g").attr("class", "x axis").attr("transform", "translate(0," + (height - margin) + ")").call d3.svg.axis().scale(time_scale)
  d3.select("svg").append("g").attr("class", "y axis").attr("transform", "translate(" + margin + ",0)").call d3.svg.axis().scale(count_scale).tickFormat((d) ->
    count_scale.tickFormat(4, d3.format(",d")) d
  ).orient("left")
  return
d3.json("/users.json", draw)
