---@diagnostic disable: need-check-nil

local lib = require 'scripts.lib'
local util = require 'util'

local big_chest = table.deepcopy(data.raw.container['steel-chest'])
local big_chest_corpse = table.deepcopy(data.raw.corpse['steel-chest-remnants'])

big_chest.name = 'kashmiras-big-chest'
big_chest_corpse.name = 'kashmiras-big-chest-remnants'
big_chest.corpse = 'kashmiras-big-chest-remnants'
big_chest.minable.results = {{type='item', name='kashmiras-big-chest', amount=1}}

big_chest.collision_box = {{-0.7,-0.7}, {0.7,0.7}}
big_chest.selection_box = {{-1,-1}, {1,1}}

big_chest.localised_name = nil

big_chest.subgroup = 'kashmiras-big-beautiful-chests'

big_chest.inventory_size = 96
big_chest.inventory_type = 'with_filters_and_bar'

lib.map_shifts(big_chest.circuit_connector, function(c) return {c[1] + 0.5, c[2] + 0.5} end)
lib.set_scale(big_chest.picture, 2)
lib.set_scale(big_chest.water_reflection, 2)
lib.set_scale(big_chest_corpse.animation, 2)

big_chest.picture.layers[1].scale = 0.5
big_chest.picture.layers[1].width = 136
big_chest.picture.layers[1].height = 168
big_chest.picture.layers[1].filename = '__kashmiras-big-beautiful-chests__/graphics/big-chest.png'

lib.insert(big_chest.flags, "get-by-unit-number")

local big_chest_item = table.deepcopy(data.raw.item['steel-chest'])
big_chest_item.name='kashmiras-big-chest'
big_chest_item.localised_name = nil
big_chest_item.stack_size = 20
big_chest_item.place_result = 'kashmiras-big-chest'
big_chest_item.weight = 1000000 / 10
big_chest_item.order = 'a'
big_chest_item.subgroup = 'kashmiras-big-beautiful-chests'
big_chest_item.icon = '__kashmiras-big-beautiful-chests__/graphics/icons/big-chest.png'

---@type data.RecipePrototype
local big_chest_recipe = {
    type = 'recipe',
    name = 'kashmiras-big-chest',
    energy_required = 1,
    order = 'a',
    subgroup = 'kashmiras-big-beautiful-chests',
    ingredients = {
        { type='item', name='steel-plate', amount=16 },
        { type='item', name='iron-gear-wheel', amount=4 },
        { type='item', name='copper-plate', amount=2 },
    },
    results = {{type='item', name='kashmiras-big-chest', amount=1}}
}

lib.insert(data.raw.technology.automation.effects, {type='unlock-recipe', recipe='kashmiras-big-chest'})

data:extend{
    big_chest,
    big_chest_corpse,
    big_chest_item,
    big_chest_recipe
}
