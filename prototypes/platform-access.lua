---@diagnostic disable: need-check-nil

-- cspell:word spap

if not mods['space-age'] then return end

local lib = require 'scripts.lib'

---@type data.CircuitConnectorDefinition?
local circuit = table.deepcopy(data.raw.container['steel-chest'].circuit_connector[1])
lib.map_shifts(circuit, function(c) return {c[1] + 1.5, c[2] + 1.0} end)

if mods['base'] >= '2.1.21' then
    circuit = { circuit, circuit, circuit, circuit }
end


---@type integer
local max_access_ports = settings.startup['kashmiras-platform-access-count'].value --[[@as integer]]

local quality_boost = 0

if settings.startup['kashmiras-platform-access-quality-boost'] then
    quality_boost = settings.startup['kashmiras-platform-access-quality-boost'].value --[[@as integer]]
end

---@type table<data.QualityID, data.LocalisedString>?
local quality_values = nil

if feature_flags.quality then

    quality_values = {}
    for _, quality in pairs(data.raw.quality) do
        quality_values[quality.name] = tostring(max_access_ports + quality_boost * quality.level)
    end
end

---@type data.CustomTooltipField
local max_ports_tooltip = {
    name = {'tooltip.kashmiras-platform-access-count'},
    value = tostring(max_access_ports),
    order = 255,
    quality_header = 'quality-tooltip.increases',
    quality_values = quality_values,
}

for _, hub in pairs(data.raw['space-platform-hub']) do
    hub.custom_tooltip_fields = hub.custom_tooltip_fields or {}
    lib.insert(hub.custom_tooltip_fields, max_ports_tooltip)
end

---@type data.ProxyContainerPrototype
local spap = {
    type = 'proxy-container',
    name = 'kashmiras-platform-access',

    icon = '__kashmiras-big-beautiful-chests__/graphics/icons/platform-access.png',
    icon_size = 64,

    circuit_wire_max_distance = 9,

    circuit_connector = { circuit, circuit, circuit, circuit},

    draw_inventory_content = false,

    selection_box = { { -2, -2 }, { 2, 2 } },
    collision_box = { { -1.7, -1.7 }, { 1.7, 1.7 } },

    surface_conditions = {
      { property = 'gravity', max = 0 }
    },

    tile_placeability_rules = {

    },

    custom_tooltip_fields = {max_ports_tooltip},

    subgroup = 'kashmiras-space-nonsense',
    order = 'a-a',

    minable = {
        mining_time = 0.5,
        results = {
            { type = 'item', amount = 1, name = 'kashmiras-platform-access' }
        }
    },

    build_grid_size = 2,

    flags = {
        'placeable-player',
        'placeable-neutral',
        'player-creation',
    },

    picture = {
        layers = {
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/platform-access.png',
                width = 538,
                height = 532,
                shift = { 0, 0 },
                scale = 0.25,
            },
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/platform-access-shadow.png',
                width = 363,
                draw_as_shadow = true,
                height = 238,
                shift = { 0, 0 },
                scale = 0.25,
            }
        },
    }
}

---@type data.ItemPrototype
local spap_item = table.deepcopy(data.raw.item['landing-pad-unloading-bay'])

spap_item.name = 'kashmiras-platform-access'
spap_item.icon = '__kashmiras-big-beautiful-chests__/graphics/icons/platform-access.png'
spap_item.subgroup = spap.subgroup
spap_item.order = spap.order

spap_item.place_result = 'kashmiras-platform-access'

---@type data.RecipePrototype
local spap_recipe = table.deepcopy(data.raw.recipe['landing-pad-unloading-bay'])

spap_recipe.name = 'kashmiras-platform-access'
spap_recipe.ingredients = {
    { type='item', name='processing-unit', amount=8 },
    { type='item', name='electric-engine-unit', amount=15 },
    { type='item', name='pipe-to-ground', amount=10 },
    { type='item', name='cargo-bay', amount=1 },
}

spap_recipe.results = {
    { type='item', name='kashmiras-platform-access', amount=1 },
}

lib.insert(data.raw.technology['landing-pad-unloading-bay'].effects,
    { type='unlock-recipe', recipe='kashmiras-platform-access'}, 2
)

data:extend{spap, spap_item, spap_recipe}