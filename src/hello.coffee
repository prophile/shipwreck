$ ->
  console.log "Hello, world!"

  environment = GameState.state.map((x) -> x.world)

  cameraInfo = Bacon.combineTemplate
    camWidth: K('camera_width')
    camHeight: K('camera_height')

  cameraInfo = cameraInfo.skipDuplicates _.isEqual

  gridDisplay = Bacon.never().toProperty [
    [['bg_water'], ['bg_water'], ['bg_shipwreck'], ['bg_water']],
    [['bg_water'], ['bg_plains'], ['bg_plains'], ['bg_water']],
    [['bg_water'], ['bg_water'], ['bg_water'], ['bg_water']]]

  clicks = cameraInfo.flatMapLatest (info) ->
    {camWidth, camHeight} = info
    sources = (for row in [0..camHeight-1]
      for col in [0..camWidth-1]
        do (row, col) ->
          gridDisplay.map((x) -> x[row]?[col] ? ['unknown']))
    GridView '#tiles', sources

  clicks.onValue (pos) ->
    [x, y] = pos
    console.log "Click at #{x}, #{y}"
