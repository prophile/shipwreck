$ ->
  console.log "Hello, world!"

  environment = GameState.state.map((x) -> x.world)

  cameraInfo = Bacon.combineTemplate
    camWidth: K('camera_width')
    camHeight: K('camera_height')

  cameraInfo = cameraInfo.skipDuplicates _.isEqual

  gridDisplay = environment.map((env) ->
    for row in env
      for cell in row
        switch cell
          when 0 then ['bg_water']
          when 1 then ['bg_plains']
          when 2 then ['bg_tree']
          when 3 then ['bg_shipwreck']
          when 4 then ['bg_stone']
          when 5 then ['bg_iron']
          when 6 then ['bg_plains'] # roads
          else ['unknown'])

  gridDisplay.onValue (x) -> console.log x

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

  GameState.start
    world: [
      [0, 0, 0, 0, 0, 0],
      [0, 1, 2, 1, 0, 0],
      [0, 1, 1, 2, 1, 0],
      [0, 3, 1, 1, 4, 0],
      [0, 0, 2, 1, 5, 0],
      [0, 0, 0, 2, 4, 0],
      [0, 0, 0, 0, 0, 0]]
