---@diagnostic disable: need-check-nil

local lib = require 'scripts.lib'

---@type data.ProxyContainerPrototype
local big_extender = table.deepcopy(data.raw.container['kashmiras-big-chest']) --[[@as data.ProxyContainerPrototype]]

big_extender.type = 'proxy-container'
big_extender.name = 'kashmiras-big-extender'
big_extender.minable.results = {{type='item', name='kashmiras-big-extender', amount=1}}
big_extender.subgroup = 'kashmiras-big-beautiful-chests'
big_extender.picture.layers[1].filename = '__kashmiras-big-beautiful-chests__/graphics/big-extender.png'



local extender_item = table.deepcopy(data.raw.item['kashmiras-big-chest'])
extender_item.name='kashmiras-big-extender'
extender_item.place_result = 'kashmiras-big-extender'
extender_item.order = 'a-c'
extender_item.icon = '__kashmiras-big-beautiful-chests__/graphics/icons/big-extender.png'

---@type data.RecipePrototype
local extender_recipe = {
    type = 'recipe',
    name = 'kashmiras-big-extender',
    energy_required = 1,
    order = 'a-c',
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
