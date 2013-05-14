$ ->
  console.log "Hello, world!"

  environment = GameState.state.map((x) -> x.world)

  cameraTopLeft = GameState.state.map((x) -> x.camera)
  cameraTopLeft.onValue (x) -> console.log "Camera", x

  cameraInfo = Bacon.combineTemplate
    camWidth: K('camera_width')
    camHeight: K('camera_height')
    offscreenTile: K('tile_offscreen')

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
    {camWidth, camHeight, offscreenTile} = info
    sources = (for row in [0..camHeight-1]
      for col in [0..camWidth-1]
        do (row, col) ->
          intermediate = Bacon.combineTemplate
            grid: gridDisplay
            target: cameraTopLeft
          intermediate.map (x) ->
            {grid, target} = x
            [tx, ty] = target
            grid[row + ty]?[col + tx] ? [offscreenTile])
    GridView '#tiles', sources

  clicks.onValue (pos) ->
    [x, y] = pos
    console.log "Click at #{x}, #{y}"

  GameState.start
    camera: [0, 0]
    world: [
      [0, 0, 0, 0, 0, 0],
      [0, 1, 2, 1, 0, 0],
      [0, 1, 1, 2, 1, 0],
      [0, 3, 1, 1, 4, 0],
      [0, 0, 2, 1, 5, 0],
      [0, 0, 0, 2, 4, 0],
      [0, 0, 0, 0, 0, 0]]

  # dat mutation?
  bindMotion = (key, x, y) ->
    key.onValue ->
      GameState.mutate "camera motion", (state) ->
        state.camera[0] += x
        state.camera[1] += y
  bindMotion Keys.down, 0, 1
  bindMotion Keys.up, 0, -1
  bindMotion Keys.left, -1, 0
  bindMotion Keys.right, 1, 0

  # clear options on click
  Command.select.plug clicks.debounce(100)

  target = cameraTopLeft.sampledBy(clicks, (cam, click) ->
    [cam[0] + click[0], cam[1] + click[1]])
  inBounds = (pos, state) ->
    return false unless pos[0] >= 0
    return false unless pos[1] >= 0
    return false unless pos[1] < state.world.length
    return false unless pos[1] < state.world[pos[1]].length
    true

  clicksInMode = (mode) ->
    inMode = Command.mode.map((x) -> x is mode)
    Utils.under(target, inMode)

  # deforestation
  clicksInMode('deforest').onValue (pos) ->
    GameState.mutate "deforestation", (state) ->
      return unless inBounds pos, state
      return unless state.world[pos[1]][pos[0]] is 2
      state.world[pos[1]][pos[0]] = 1

