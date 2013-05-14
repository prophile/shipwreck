window.GridView = (element, cells) ->
  CELL_SIZE = 32
  element = $(element)
  context = element.get(0).getContext '2d'

  # get the spritesheet
  ssElement = $('#spritesheet')
  spritesheet = ssElement.asEventStream('load')
                         .map(ssElement.get(0))

  height = cells.length
  width = cells[0]?.length ? 0

  element.attr('height', "#{height*32}px")
  element.attr('width', "#{width*32}px")

  DrawCommands = new Bacon.Bus
  Clicks = new Bacon.Bus

  eventToPosition = (x) ->
    [Math.floor(x.clientX / CELL_SIZE),
     Math.floor(x.clientY / CELL_SIZE) - 1]

  DownClick = element.asEventStream('mousedown')
                     .map(eventToPosition)
  UpClick = element.asEventStream('mouseup')
                   .map(eventToPosition)
  DownLocation = DownClick.merge(UpClick.map(null).delay(0))
                          .toProperty(null)
  clicks = DownLocation.sampledBy(UpClick, (down, up) -> [down, up])
                       .filter((x) -> _.isEqual(x[0], x[1]))
                       .map((x) -> x[0])

  for r in [0..height-1]
    for c in [0..width-1]
      do (r, c) ->
        stream = cells[r][c]
        sources = Bacon.combineTemplate
          elements: stream
          spritesheet: spritesheet
          sprites: K('sprites')
        sources.onValue (x) ->
          {elements, spritesheet, sprites} = x
          return unless elements?
          return unless spritesheet?
          return unless sprites?
          for element in elements
            [sx, sy, sw, sh] = sprites[element] ? sprites['unknown']
            context.drawImage spritesheet,
                              sx, sy, sw, sh,
                              c*CELL_SIZE, r*CELL_SIZE,
                              CELL_SIZE, CELL_SIZE

  clicks

