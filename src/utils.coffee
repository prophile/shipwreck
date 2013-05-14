under = (stream, property) ->
  # a horrible hack, admittedly
  outputBus = new Bacon.Bus
  isLive = false
  property.onValue (x) ->
    isLive = x
  stream.filter(-> isLive)

window.Utils =
  under: under

