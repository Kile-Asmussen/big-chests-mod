
local lib = require 'scripts.lib'

local wide_chest = table.deepcopy(data.raw.container['steel-chest'])

wide_chest.name = "kashmiras-wide-chest"
wide_chest.collision_box = {
    { -2.7, -0.7 }, { 2.7, 0.7 }
}
wide_chest.selection_box = {
    { -3, -1 }, { 3, 1 }
}

wide_chest.picture = {
    north = {
        layers = {
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/tall-chest.png',
                priority = "extra-high",
                width = 128,
                height = 416,
                scale = 0.5
            },
            {
                filename = "__base__/graphics/entity/steel-chest/steel-chest-shadow.png",
                priority = "extra-high",
                width = 110,
                height = 46,
                shift = { 0.3828125*2 + 2, 0.5 },
                draw_as_shadow = true,
                scale = 1.0
            }
        }
    },
    east = {
        layers = {
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/tall-chest.png',
                width = 128,
                height = 416,
                scale = 0.5
            },
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/tall-chest-shadow.png',
                width = 110,
                height = 138,
                scale = 1.0,
                shift = { 0.3828125*2, 0.5 },
            },
        }
    }
}
wide_chest.picture.south = wide_chest.picture.north
wide_chest.picture.west = wide_chest.picture.east

wide_chest.max_health = 1500
wide_chest.inventory_size = 144

data:extend{wide_chest}