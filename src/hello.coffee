$ ->
  console.log "Hello, world!"

  cameraTopLeft = GameState.state.map((x) -> x.camera)
  cameraTopLeft.onValue (x) -> console.log "Camera", x

  cameraInfo = Bacon.combineTemplate
    camWidth: K('camera_width')
    camHeight: K('camera_height')
    offscreenTile: K('tile_offscreen')

  cameraInfo = cameraInfo.skipDuplicates _.isEqual

  gridDisplay = GameState.state.map((state) ->
    for row, rowIndex in state.world
      for cell, cellIndex in row
        basis = switch cell
          when 0 then ['bg_water']
          when 1 then ['bg_plains']
          when 2 then ['bg_tree']
          when 3 then ['bg_stone']
          when 4 then ['bg_iron']
          when 5 then ['bg_shipwreck']
          when 6 then ['bg_plains'] # roads
          else ['unknown']
        # dig out entities
        for entity in state.entities
          [ex, ey] = entity.pos
          for entityRow, entityRowIndex in entity.sprites
            for entityCell, entityColIndex in entityRow
              if _.isEqual([cellIndex, rowIndex],
                           [ex + entityColIndex,
                            ey + entityRowIndex])
                basis.push entityCell
        basis)

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

  GenerateMap.push true

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

  cameraTargetInfo = Bacon.combineTemplate
    topLeft: cameraTopLeft
    offset: K('camera_offset')
  target = cameraTargetInfo.sampledBy(clicks, (cam, click) ->
    {topLeft, offset} = cam
    [topLeft[0] + offset[0] + click[0],
     topLeft[1] + offset[1] + click[1]])
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
      #return unless state.world[pos[1]][pos[0]] is 2
      state.world[pos[1]][pos[0]] = 1

