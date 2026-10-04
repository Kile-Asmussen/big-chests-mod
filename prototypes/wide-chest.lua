---@diagnostic disable: need-check-nil

local lib = require 'scripts.lib'

local wide_chest = table.deepcopy(data.raw.container['steel-chest'])

wide_chest.name = "kashmiras-wide-chest"
wide_chest.collision_box = {
    { -2.7, -0.7 }, { 2.7, 0.7 }
}
wide_chest.selection_box = {
    { -3, -1 }, { 3, 1 }
}

wide_chest.direction_count = 2

wide_chest.circuit_connector[2] = table.deepcopy(wide_chest.circuit_connector[1])

lib.map_shifts(wide_chest.circuit_connector[1], function(c) return {c[1] + 2.5, c[2] + 0.5} end)
lib.map_shifts(wide_chest.circuit_connector[2], function(c) return {c[1] + 0.5, c[2] + 2.5} end)

wide_chest.picture = {
    north = {
        layers = {
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/wide-chest.png',
                priority = "extra-high",
                width = 384,
                height = 160,
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
                draw_as_shadow = true,
                height = 167,
                scale = 1.0,
                shift = { 0.3828125*2, 0.5 },
            },
        }
    }
}

wide_chest.picture.south = wide_chest.picture.north
wide_chest.picture.west = wide_chest.picture.east

wide_chest.max_health = 1500
wide_chest.inventory_size = 96

wide_chest.minable.result = nil
wide_chest.minable.results = {{ type='item', name=wide_chest.name, amount=1 }}
wide_chest.minable.mining_time = 2

wide_chest.subgroup = 'kashmiras-big-beautiful-chests'
wide_chest.order = 'c-a'

wide_chest.icons = {
    { icon = '__base__/graphics/icons/steel-chest.png', icon_size = 64, scale = 0.5 },
    { icon = '__base__/graphics/icons/arrows/left-arrow.png', icon_size = 64, scale = 0.25, shift = { -10, 0 }, floating = true },
    { icon = '__base__/graphics/icons/arrows/right-arrow.png', icon_size = 64, scale = 0.25, shift = { 10, 0 }, floating = true },
}

---@type data.ItemPrototype
local wide_item = table.deepcopy(data.raw.item['steel-chest'])

wide_item.name = wide_chest.name
wide_item.weight = 1000000 / 10
wide_item.stack_size = 10
wide_item.place_result = wide_chest.name
wide_item.icons = wide_chest.icons
wide_item.subgroup = wide_chest.subgroup
wide_item.order = wide_chest.order

---@type data.RecipePrototype
local wide_recipe = {
    type = 'recipe',
    name = wide_item.name,
    energy_required = 2,
    ingredients = {{ type="item", name="steel-chest", amount = 6 }},
    results = {{ type='item', name=wide_item.name, amount = 1}}
}
lib.insert(data.raw.technology.railway.effects, { type='unlock-recipe', recipe=wide_recipe.name })

local wide_chest_remnants = table.deepcopy(data.raw.corpse['steel-chest-remnants'])
wide_chest_remnants.name = 'kashmiras-wide-chest-remnants'

lib.set_scale(wide_chest_remnants.animation, 2)

data:extend{wide_chest, wide_item, wide_recipe, wide_chest_remnants}