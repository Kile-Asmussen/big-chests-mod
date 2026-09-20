
local lib = require 'scripts.lib'
local util = require 'util'

local big_steel_chest = table.deepcopy(data.raw.container['steel-chest'])
local big_steel_chest_corpse = table.deepcopy(data.raw.corpse['steel-chest-remnants'])

big_steel_chest.name = 'kashmiras-steel-chest'
big_steel_chest_corpse.name = 'kashmiras-steel-chest-remnants'

big_steel_chest.corpse = 'kashmiras-steel-chest-remnants'

lib.map_shifts(big_steel_chest.circuit_connector, function(c) return {c[1] + 0.5, c[2] + 0.5} end)

lib.set_scale(big_steel_chest.picture, 2)
lib.set_scale(big_steel_chest.water_reflection, 2)
lib.set_scale(big_steel_chest_corpse.animation, 2)

local big_steel_chest = table.deepcopy(data.raw.container['steel-chest'])
