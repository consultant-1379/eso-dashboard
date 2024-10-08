class Dashing.EsoJobs extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    # This is fired when the widget receives data
    #$(@node).fadeOut().fadeIn()
    #extract widget paramaters
    @max_displayed_samples = @get('max_samples')
    @display_job_titles = @get('show_job_titles')
    @display_build_number = @get('show_build_number')
    @display_sample_spacers = @get('sample_spacers')
    @flash_failed_builds = @get('flash_failed_builds')


    container = $(@node).parent()
    # code from graph.coffee
    widget_width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    widget_height = (Dashing.widget_base_dimensions[1] * container.data("sizey")) + Dashing.widget_margins[1] * 2 * (container.data("sizey") - 1)

    chart_inner_margin = 0

    #calculate canvas size
    canvas_width = widget_width - chart_inner_margin
    canvas_height = widget_height - chart_inner_margin

    #calculate sample bar width
    sample_bar_width = 10

    unless @max_displayed_samples is 0

      #adjust if spacers between samples
      if @display_sample_spacers
        sample_bar_width = (canvas_width - @max_displayed_samples) / @max_displayed_samples
      else
       sample_bar_width = canvas_width / @max_displayed_samples


    #calculate sample bar height
    row_height = 30
    @number_jenkins_jobs = data.jenkins_jobs.length

    unless @number_jenkins_jobs is 0

      #adjust if spacers between samples
      if @display_sample_spacers
        row_height = (canvas_height - @number_jenkins_jobs) / @number_jenkins_jobs
      else
       row_height = canvas_height / @number_jenkins_jobs


    #hash Jenkins build status values ('ball color' => HTML colour values)
    #reference: https://github.com/jenkinsci/jenkins/blob/master/core/src/main/java/hudson/model/BallColor.java
    #use a green sample colour for success as opposed to native Jenkins 'blue'

    #NOTE: disabled, aborted and not built states map to the same colour for simplicity
    #all 'xxx_anime' colours represent currently building jobs.
    #here, they all map to the same sample colour for simplicity

    @jenkins_job_status_colour_map =
      red: "#9b2d23"
      failure: "#9b2d23"
      failed: "#9b2d23"
      yellow: "#ff9618"
      blue: "#6699ff"
      building: "#6699ff"
      success: "#62D146"
      passed: "#62D146"
      grey: "#A4A4A4"
      disabled: "#6E6E6E"
      aborted: "#6E6E6E"
      nobuilt: "#6E6E6E"
      red_anime: "#D8D8D8"
      blue_anime: "#D8D8D8"
      grey_anime: "#D8D8D8"
      disabled_anime: "#D8D8D8"
      aborted_anime: "#D8D8D8"
      nobuilt_anime: "#D8D8D8"
      unstable: "#ff9618"

    #remove child elements of previously rendered canvas object
    if $("#esoJobsHistory")
      $("#esoJobsHistory").empty()

    #create new canvas object
    @raphael_canvas = Raphael("esoJobsHistory", canvas_width, canvas_height )


    y_index = 0

    #loop through job status data and render to widget
    for job_entry of data.jenkins_jobs
      extracted_job_entry = data.jenkins_jobs[job_entry]

      #render status history for an entire job
      @_render_job_status_row @raphael_canvas, 0, y_index, sample_bar_width, row_height, extracted_job_entry, @flash

      #increment row
      y_index = y_index + row_height

      #add spacer if required
      if @display_sample_spacers
        y_index = y_index + 1


  # This function renders the build status history for a single job
  _render_job_status_row: (@raphael_canvas, row_x, row_y, sample_bar_width, height, job_object) ->

    #draw status sample bars
    num_samples = job_object.build_status.length
    x_index = row_x

    #only draw samples if there is data to be drawn...
    unless num_samples is 0
      for job_status_entry of job_object.build_status
        job_status = job_object.build_status[job_status_entry]

        #render rectangle for single sample
        rect_attributes =
        stroke: "none"
        fill: @jenkins_job_status_colour_map[job_status.status]


        rect = @raphael_canvas.rect(x_index, row_y, sample_bar_width, height).attr rect_attributes

        if x_index == 0 && @_should_build_flash(job_status.status)
          if @flash_failed_builds
            css_style = @_css_flash_style(job_status.status)
            rect.node.setAttribute("class",css_style);

        #draw job title if required
        if @display_job_titles
          @_render_job_title(@raphael_canvas, row_x, row_y, height, job_object.job_name)

        if @display_build_number
          @_render_build_number(@raphael_canvas, x_index, (row_y - 12), sample_bar_width, job_status.build_no)

        #increment X index
        x_index = x_index + sample_bar_width

        #add spacer if required
        if @display_sample_spacers
          x_index = x_index + 1



  #this function draws a job title
  _render_job_title: (@raphael_canvas, row_x, row_y, height, title) ->

    #job title text font
    txt_attributes =
    font: "26px EricssonCapitalTT, Arial"
    stroke: "none"
    "font-weight": "bold"
    fill: "#FFF"
    "text-anchor": "start"
    opacity: 0.5

    #render job title text
    @raphael_canvas.text(row_x, row_y + (height / 2), title).attr txt_attributes


  #this function draws a build number
  _render_build_number: (@raphael_canvas, row_x, row_y, height, title) ->
    #console.log(" X: ", row_x, " Y: ", row_y, " height ", height, " title", title)

    #job title text font
    txt_attributes =
    font: "14px EricssonCapitalTT, Arial"
    stroke: "none"
    "font-weight": "bold"
    fill: "#FFF"
    "text-anchor": "start"
    opacity: 0.5

    #render job title text
    @raphael_canvas.text(row_x, row_y + (height / 2), title).attr txt_attributes

  _should_build_flash: (job_status) ->
    switch job_status
      when "red"
        , "failure"
        , "failed"
        , "yellow" then return true
      else return false

  _css_flash_style: (job_status) ->
    switch job_status
      when "red"
        , "failure"
        , "failed" then return "status-warning"
      when "yellow" then return "status-danger"
      else return ""