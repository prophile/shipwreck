window.Save =
  save: new Bacon.Bus
  load: new Bacon.Bus

GameState.state
         .sampledBy(Save.save)
         .onValue((state) -> window.localStorage['WRECK_SAVE'] = JSON.stringify(state))

Save.load.onValue ->
  GameState.start JSON.parse(window.localStorage['WRECK_SAVE'])

$ ->
  Save.save.plug ($('#opt-save').asEventStream 'click')
  Save.load.plug ($('#opt-load').asEventStream 'click')
  GenerateMap.plug ($('#opt-new').asEventStream 'click')

