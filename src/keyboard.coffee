keyboardEvents = new Bacon.Bus

$ ->
  keyStream = $(document).asEventStream 'keydown'
  keyStream.doAction '.preventDefault'
  keyboardEvents.plug keyStream

getKey = (key) ->
  keyboardEvents.filter((x) -> x.keyCode == key)

window.Keys =
  up: getKey 38
  down: getKey 40
  left: getKey 37
  right: getKey 39
  escape: getKey 27
  debug: getKey 68

