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
  treeChance: percentage K('tree_chance')
  ironChance: percentage K('iron_chance')
  rockLevel: percentage K('rock_level')
  simplexBiome: percentage K('biome_simplex_scale')
  simplexRock: percentage K('rock_simplex_scale')
  simplexWater: percentage K('water_simplex_scale')
  continentRatio: percentage K('continent_ratio')
  borderWidth: K('border_width')
  hqWaterDistance: K('hq_water_distance')
  width: K('map_width')
  height: K('map_height')
  camWidth: K('camera_width')
  camHeight: K('camera_height')

generateMap = mapParameters.sampledBy(genMapCommand.delay(100))

generateMap.onValue (params) ->
  grid = ((2 for w in [0..params.width-1]) for h in [0..params.height-1])
  waterSource = new SimplexNoise
  biomeSource1 = new SimplexNoise
  biomeSource2 = new SimplexNoise
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
        waterBias = (coastDistance / params.borderWidth)
      else
        waterBias = 1
      waterThreshold = 1 - (waterBias * params.continentRatio)
      terrainLevel = Math.abs(waterSource.noise2D(x * params.simplexWater,
                                       y * params.simplexWater))
      grid[y][x] = if terrainLevel < waterThreshold then 0 else 1
      #grid[y][x] = Math.floor(waterThreshold * 5)
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
  # Step 3: generate rocks
  for x in [0..params.width-1]
    for y in [0..params.height-1]
      continue if getGrid(x, y) is 0
      # get biome
      biome = biomeSource1.noise2D(x * params.simplexRock,
                                   y * params.simplexRock)
      if biome > params.rockLevel
        grid[y][x] = 3
  # Step 4: generate trees
  for x in [0..params.width-1]
    for y in [0..params.height-1]
      continue if getGrid(x, y) isnt 1
      # get biome
      biome = biomeSource2.noise2D(x * params.simplexBiome,
                                   y * params.simplexBiome)
      isLeafy = biome < 0
      if isLeafy and Math.random() < params.treeChance
        grid[y][x] = 2
  # Step 5: generate iron
  for x in [0..params.width-1]
    for y in [0..params.height-1]
      continue if getGrid(x, y) isnt 3
      if Math.random() < params.ironChance
        grid[y][x] = 4
  # Step 6: find a location for HQ
  hqLocation = null
  for n in [0..100]
    location = [params.borderWidth + Math.floor(Math.random() * params.width - 2*params.borderWidth),
                params.borderWidth + Math.floor(Math.random() * params.height - 2*params.borderWidth)]
    # Validity conditions:
    #   1: entirely on land [all tiles are tree/plains]
    #   2: nearby water
    if _.any(_.flatten(for x in [location[0]..location[0]+2]
      for y in [location[1]..location[1]+1]
        (getGrid(x, y) is 0)))
      continue
    selectedWater = null
    for x in [location[0]-params.hqWaterDistance..location[0]+2+params.hqWaterDistance]
      for y in [location[1]-params.hqWaterDistance..location[1]+1+params.hqWaterDistance]
        if getGrid(x, y) is 0
          selectedWater = [x, y]
          break
    if not selectedWater?
      continue
    grid[selectedWater[1]][selectedWater[0]] = 5
    hqLocation = location
    break
  unless hqLocation?
    console.log 'Map generation failure: guessing HQ'
    hqLocation = [10, 10]

  hq =
    type: "hq"
    pos: hqLocation
    sprites: [["fg_hq_00", "fg_hq_10", "fg_hq_20"],
              ["fg_hq_01", "fg_hq_11", "fg_hq_21"]]
    stock:
      food: 300
      flax: 0
      lumber: 0
      planks: 0
      stone: 0
      iron: 0
      ore: 0
  GameState.start
    camera: [hqLocation[0] - ((params.camWidth - 1) / 2),
             hqLocation[1] - ((params.camHeight - 1) / 2)]
    world: grid
    entities: [hq]

window.GenerateMap = genMapCommand

