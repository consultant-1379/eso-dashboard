class Dashing.Number extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue
  @accessor 'team', Dashing.AnimatedValue

  onData: (data) ->
    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"
