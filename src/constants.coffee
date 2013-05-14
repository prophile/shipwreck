constantsBus = new Bacon.Bus

loadConstants = ->
  console.log "Loading constants..."
  rq = $.ajax 'constants.json',
              cache: true,
              dataType: 'json'

  constantsBus.plug Bacon.fromPromise(rq)

do loadConstants

allConstants = constantsBus.toProperty()

getConstant = (k) ->
  allConstants.map((x) -> x[k])
              .skipDuplicates()

window.K = getConstant
window.ReloadK = loadConstants

