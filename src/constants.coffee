constantsBus = new Bacon.Bus

rq = $.ajax 'constants.json',
            cache: true,
            dataType: 'json'

constantsBus.plug Bacon.fromPromise(rq)

allConstants = constantsBus.toProperty()

getConstant = (k) ->
  allConstants.map((x) -> x[k])
              .skipDuplicates()

window.K = getConstant

