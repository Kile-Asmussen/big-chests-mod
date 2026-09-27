---@diagnostic disable: need-check-nil

local constants = require 'scripts.constants'
local lib = require 'scripts.lib'
local util = require 'util'

---@type data.ProxyContainerPrototype
local big_extender = table.deepcopy(data.raw.container['kashmiras-big-chest']) --[[@as data.ProxyContainerPrototype]]

big_extender.type = 'proxy-container'
big_extender.name = 'kashmiras-big-extender'
big_extender.minable.results = {{type='item', name='kashmiras-big-extender', amount=1}}
big_extender.subgroup = 'kashmiras-big-beautiful-chests'
big_extender.picture.layers[1].filename = '__kashmiras-big-beautiful-chests__/graphics/big-extender.png'


---@type table<QualityID, LocalisedString>
local quality_values = {}
for _, quality in pairs(data.raw.quality) do
    quality_values[quality.name] = tostring(constants.normal_link_distance + constants.quality_distance_increase * quality.level)
end

---@type data.CustomTooltipField
local connection_distance_tooltip = {
    name = {'tooltip.kashmiras-big-extender-range'},
    value = tostring(constants.normal_link_distance),
    order = 255,
    quality_value = quality_values,
}

big_extender.custom_tooltip_fields = {

}

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
