under = (stream, property) ->
  Bacon.combineAsArray(stream, property)
       .filter((x) -> x[1])
       .map((x) -> x[0])
       .changes()

window.Utils =
  under: under

