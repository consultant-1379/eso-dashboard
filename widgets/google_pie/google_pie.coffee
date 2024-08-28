class Dashing.GooglePie extends Dashing.Widget

  ready: ->
    container = $(@node).parent()
  # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))

    colors = null
    if @get('colors')
      colors = @get('colors').split(/\s*,\s*/)

    @chart = new google.visualization.PieChart($(@node).find(".chart")[0])
    @options =
      height: height
      width: width
      colors: colors
      fontSize: 27
      is3D: @get('is_3d')
      pieSliceText: @get('pie_slice_text')
      pieHole: @get('pie_hole')
      pieStartAngle: @get('pie_start_angle')
      backgroundColor: 'transparent'
      legend:
        position: @get('legend_position')
        textStyle: 
          bold: true
      chartArea:
        left: 10
        top: 100
        width: "100%"
        height: "100%"

    if @get('slices')
      @data = google.visualization.arrayToDataTable @get('slices')
    else
      @data = google.visualization.arrayToDataTable []

    @chart.draw @data, @options

  onData: (data) ->
    if @chart
      @data = google.visualization.arrayToDataTable data.slices
      @chart.draw @data, @options
