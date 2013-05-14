$ ->
  console.log "Hello, world!"

  base_grid = [
    '*************',
    '****###***#**',
    '**######*!#**',
    '*###########*',
    '*###**######*',
    '*##***####***',
    '*##***##*****',
    '**#####******',
    '****####*****',
    '******#####**',
    '********##***',
    '********#****',
    '*************'
  ]

  never = Bacon.never()
  sources = (for row in base_grid
    for cell in row
      switch cell
        when '*' then never.toProperty ['bg_water']
        when '#' then never.toProperty ['bg_plains']
        when '!' then never.toProperty ['bg_shipwreck']
        else never.toProperty ['unknown'])

  clicks = GridView '#tiles', sources

