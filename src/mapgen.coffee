genMapCommand = new Bacon.Bus

percentage = (x) ->
  x.map((x) -> x / 100)

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
  simplexWater: percentage K('water_simplex_scale')
  continentRatio: percentage K('continent_ratio')
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
  grid = ((2 for w in [0..params.width-1]) for h in [0..params.height-1])
  waterSource = new SimplexNoise
  getGrid = (x, y) ->
    return 0 if x < 0
    return 0 if y < 0
    return 0 if x >= params.width
    return 0 if y >= params.height
    return grid[y][x]
  # Step 1: generate landform
  for x in [0..params.width-1]
    for y in [0..params.height-1]
      coastDistance = Math.min(x, y,
                               params.width - x - 1,
                               params.height - y - 1)
      waterBias = 0
      if coastDistance <= params.borderWidth
        waterBias = (coastDistance - 1) / params.borderWidth
      else
        waterBias = 1
      waterThreshold = params.continentRatio * (1 - waterBias)
      waterLevel = Math.abs(waterSource.noise2D(x * params.simplexWater,
                                       y * params.simplexWater))
      grid[y][x] = if waterLevel < waterThreshold then 0 else 1
  # Step 2: erode landform
  grid = (for y in [0..params.height-1]
    for x in [0..params.width-1]
      # collect neighbours
      elements = [getGrid(x, y),
                  getGrid(x, y + 1),
                  getGrid(x, y - 1),
                  getGrid(x + 1, y),
                  getGrid(x - 1, y)]
      # include?
      isLand = _.all(elements, (x) -> x is 1)
      if isLand then 1 else 0)
  GameState.start
    camera: [0, 0]
    world: grid

window.GenerateMap = genMapCommand

