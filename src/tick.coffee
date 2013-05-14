window.EntityTypes =
  hq: (instance, state) ->
    true

window.RunTick = new Bacon.Bus

RunTick.onValue ->
  GameState.mutate 'tick', (state) ->
    # update each entity in turn
    state.entities = _.flatten((for entity in state.entities
      keep = EntityTypes[entity.type](entity, state)
      if keep then [entity] else []), true)

$ ->
  RunTick.plug Keys.space.map(true)
  #RunTick.plug Bacon.repeatedly(5*1000, [false])

