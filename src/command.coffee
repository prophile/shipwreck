cmodeBus = new Bacon.Bus
cmode = cmodeBus.toProperty('select')
                .skipDuplicates()

deforestBus = new Bacon.Bus

plugModeSelector = (commandStream, mode) ->
  cmodeBus.plug cmode.sampledBy(commandStream)
                     .map((x) -> x isnt mode)
                     .map((x) -> if x then mode else 'select')

plugModeSelector deforestBus, 'deforest'

selectBus = new Bacon.Bus
cmodeBus.plug selectBus.map('select')

window.Command =
  mode: cmode
  deforest: deforestBus
  select: selectBus

$ ->
  bindButton = (command, button) ->
    clickStream = $(button).asEventStream 'click'
    clickStream.doAction '.preventDefault'
    command.plug clickStream
  # Bind up the deforest button
  bindButton Command.deforest, '#opt-deforest'
  Command.mode.map((x) -> x is 'deforest')
              .assign $('#opt-deforest').parent(), 'toggleClass', 'active'

cmode.onValue((x) -> console.log "Command mode", x)

