genMapCommand = new Bacon.Bus

percentage = (x) ->
  x.map(x / 100)

mapParameters = Bacon.combineTemplate
  #initialFood: K('initial_food')
  #initialLumber: K('initial_lumber')
  #initialStone: K('initial_stone')
  #initialOre: K('initial_ore')
  #initialIron: K('initial_iron')
  #initialShips: K('initial_ships')
  #initialPlanks: K('initial_planks')
  #initialFlax: K('initial_flax')
  #ironChance: percentage K('iron_chance')
  #continentRatio: percentage K('continent_ratio')
  borderWidth: K('border_width')
  #hqWaterDistance: K('hq_water_distance')
  width: K('map_width')
  height: K('map_height')

mapParameters.onValue (params) ->
  console.log "Mapgen params: ", params
genMapCommand.onValue ->
  console.log "Map gen command received."

generateMap = mapParameters.sampledBy(genMapCommand.delay(100))

generateMap.onValue (params) ->
  grid = ((0 for w in [0..params.width-1]) for h in [0..params.height-1])
  for x in [0..params.width-1]
    for y in [0..params.height-1]
      if (x >= params.borderWidth and
          y >= params.borderWidth and
          x < params.width - params.borderWidth and
          y < params.height - params.borderWidth)
        grid[y][x] = 1
  GameState.start
    camera: [0, 0]
    world: grid

window.GenerateMap = genMapCommand

