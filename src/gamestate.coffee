history = new Bacon.Bus
positionInHistory = new Bacon.Bus

hisProp = history.toProperty()
posProp = positionInHistory.skipDuplicates()
                           .toProperty()

stateSource = Bacon.combineTemplate
  history: hisProp
  pos: posProp

stateProperty = stateSource.map((s) -> s.history[s.pos][1])
                           .skipDuplicates()

window.GameState =
  state: stateProperty.map(JSON.parse)
  mutate: (description, transform) ->
    stateSource.onValue (x) ->
      [currentHistory, pos] = [x.history, x.pos]
      currentState = currentHistory[pos][1]
      _.defer ->
        rawState = JSON.parse(currentState)
        transform rawState
        newHistory = currentHistory[0..pos]
        newHistory.push [description, JSON.stringify(rawState)]
        history.push newHistory
        positionInHistory.push pos + 1
      Bacon.noMore
  history: hisProp.map((x) -> [desc, JSON.parse(state)] for [desc, state] in x)
  historicalPosition: posProp
  back: (pos) ->
    positionInHistory.push pos
  start: (initialState) ->
    positionInHistory.push 0
    history.push [["initial state", JSON.stringify(initialState)]]

