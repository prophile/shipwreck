cmodeBus = new Bacon.Bus
cmode = cmodeBus.toProperty('select')
                .skipDuplicates()

buildTypeBus = new Bacon.Bus
buildType = buildTypeBus.toProperty()
                        .skipDuplicates()

buildTypeBus.plug cmodeBus.filter((x) -> x isnt 'build')
                          .map(null)

deforestBus = new Bacon.Bus
demolishBus = new Bacon.Bus

plugModeSelector = (commandStream, mode) ->
  cmodeBus.plug cmode.sampledBy(commandStream)
                     .map((x) -> x isnt mode)
                     .map((x) -> if x then mode else 'select')

plugModeSelector deforestBus, 'deforest'
plugModeSelector demolishBus, 'demolish'
plugModeSelector buildTypeBus.filter((x) -> x?), 'build'

selectBus = new Bacon.Bus
cmodeBus.plug selectBus.map('select')

window.Command =
  mode: cmode
  buildType: buildType
  deforest: deforestBus
  demolish: demolishBus
  select: selectBus
  build: buildTypeBus

$ ->
  bindButton = (command, button, what = true) ->
    clickStream = $(button).asEventStream 'click'
    clickStream.doAction '.preventDefault'
    command.plug clickStream.map(what)
  # Bind up the deforest button
  bindButton Command.deforest, '#opt-deforest'
  Command.mode.map((x) -> x is 'deforest')
              .assign $('#opt-deforest').parent(), 'toggleClass', 'active'
  bindButton Command.demolish, '#opt-demolish'
  Command.mode.map((x) -> x is 'demolish')
              .assign $('#opt-demolish').parent(), 'toggleClass', 'active'
  Command.mode.map((x) -> x is 'build')
              .assign $('#opt-build').parent(), 'toggleClass', 'active'
  for building in ['farm', 'mill', 'forester', 'woodcutter', 'sawmill']
    do (building) ->
      key = "#opt-build-#{building}"
      bindButton Command.build, key, building
      Command.buildType.map((x) -> x is building)
                       .assign $(key).parent(), 'toggleClass', 'active'

cmode.onValue((x) -> console.log "Command mode", x)

