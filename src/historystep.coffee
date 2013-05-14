$ ->
  $('#reload-consts').on 'click', ReloadK
  sources = Bacon.combineTemplate
    history: GameState.history
    position: GameState.historicalPosition
  sources.onValue (x) ->
    {history, position} = x
    $('#history').empty()
    prevElement = null
    prevElementCount = 0
    prevElementType = null
    for element, elPosition in history
      type = element[0]
      if type is prevElementType
        object = prevElement
      else
        object = $('<li>')
        $('#history').prepend(object)
        prevElementCount = 0
      prevElementCount += 1
      object.text "#{prevElementCount} x #{type} "
      restoreLink = $('<a href="#">')
      restoreLink.text 'restore'
      do (elPosition) ->
        restoreLink.on 'click', ->
          GameState.back elPosition
      object.append restoreLink
      object.css('font-weight', 'bold') if elPosition is position
      prevElement = object
      prevElementType = type

