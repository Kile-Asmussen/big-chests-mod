---@diagnostic disable: need-check-nil

local lib = require 'scripts.lib'
local util = require 'util'

---@type data.ProxyContainerPrototype
local big_extender = table.deepcopy(data.raw.container['steel-chest'])

big_extender.type = 'proxy-container'
big_extender.name = 'kashmiras-big-extender'
big_extender.corpse = 'kashmiras-big-chest-remnants'
big_extender.minable.results = {{type='item', name='kashmiras-big-extender', amount=1}}

big_extender.collision_box = {{-0.7,-0.7}, {0.7,0.7}}
big_extender.selection_box = {{-0.7,-0.7}, {0.7,0.7}}

big_extender.localised_name = nil

big_extender.subgroup = 'kashmiras-big-beautiful-chests'

lib.map_shifts(big_extender.circuit_connector, function(c) return {c[1] + 0.5, c[2] + 0.5} end)
lib.set_scale(big_extender.picture, 2)
lib.set_scale(big_extender.water_reflection, 2)

big_extender.picture.layers[1].scale = 0.5
big_extender.picture.layers[1].width = 136
big_extender.picture.layers[1].height = 168
big_extender.picture.layers[1].filename = '__kashmiras-big-beautiful-chests__/graphics/big-extender.png'

lib.insert(big_extender.flags, "get-by-unit-number")

local extender_item = table.deepcopy(data.raw.item['steel-chest'])
extender_item.name='kashmiras-big-extender'
extender_item.localised_name = nil
extender_item.stack_size = 20
extender_item.place_result = 'kashmiras-big-extender'
extender_item.weight = 1000000 / 10
extender_item.order = 'a-b'
extender_item.subgroup = 'kashmiras-big-beautiful-chests'
extender_item.icon = '__kashmiras-big-beautiful-chests__/graphics/icons/big-extender.png'

---@type data.RecipePrototype
local extender_recipe = {
    type = 'recipe',
    name = 'kashmiras-big-extender',
    energy_required = 1,
    order = 'a-b',
    subgroup = 'kashmiras-big-beautiful-chests',
    ingredients = {
        { type='item', name='kashmiras-big-chest', amount=1 },
        { type='item', name='electronic-circuit', amount=10 },
    },
    results = {{type='item', name='kashmiras-big-extender', amount=1}}
}

lib.insert(data.raw.technology['automation-2'].effects, {type='unlock-recipe', recipe='kashmiras-big-extender'})

data:extend{
    big_extender,
    extender_item,
    extender_recipe
}
