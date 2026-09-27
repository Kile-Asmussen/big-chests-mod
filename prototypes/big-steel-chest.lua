
local lib = require 'scripts.lib'
local util = require 'util'

local big_chest = table.deepcopy(data.raw.container['steel-chest'])
local big_chest_corpse = table.deepcopy(data.raw.corpse['steel-chest-remnants'])

big_chest.name = 'kashmiras-big-chest'
big_chest_corpse.name = 'kashmiras-big-chest-remnants'
big_chest.corpse = 'kashmiras-big-chest-remnants'

big_chest

lib.map_shifts(big_chest.circuit_connector, function(c) return {c[1] + 0.5, c[2] + 0.5} end)

lib.set_scale(big_chest.picture, 2)
big_chest.picture.scale = 0.5
big_chest.picture.filename = '__kashmiras-big-beautiful-chests__/graphics/big-chest.png'
lib.set_scale(big_chest.water_reflection, 2)
lib.set_scale(big_chest_corpse.animation, 2)

---@type 
local big_chest_item

data:extend{
    big_chest,
    big_chest_corpse
}
