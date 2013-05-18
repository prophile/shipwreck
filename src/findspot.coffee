window.FindSpot = (map, position, dims, permitted = [1]) ->
  getCell = (x, y) ->
    map[y]?[x] ? 0
  validHere = (x, y) ->
    for xOff in [0..dims[0]-1]
      for yOff in [0..dims[1]-1]
        xH = x + xOff
        yH = y + yOff
        return false if not (getCell(xH, yH) in permitted)
    true
  console.log "Hunting around #{position[0]}, #{position[1]}"
  for x in [0..dims[0]-1]
    for y in [0..dims[1]-1]
      xTL = position[0] - x
      yTL = position[1] - y
      console.log "Trying #{xTL}, #{yTL}"
      return [xTL, yTL] if validHere(xTL, yTL)
  return null


