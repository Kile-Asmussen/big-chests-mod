---@diagnostic disable: need-check-nil

if not mods['space-age'] then return end

local lib = require 'scripts.lib'

local big_chest = table.deepcopy(data.raw.container['steel-chest'])

---@type data.Sprite[]
local picture_layers = {
    {
        priority = "extra-high",
        filename = '__kashmiras-big-beautiful-chests__/graphics/platform-access.png',
        width = 538,
        height = 532,
        shift = { 0, 0 }
    },
    {
        priority = "extra-high",
        filename = '__kashmiras-big-beautiful-chests__/graphics/platform-access-shadow.png',
        width = 538,
        height = 532,
        shift = { 0, 0 }
    },
}

---@type data.CircuitConnectorDefinition
local circuit = table.deepcopy(data.raw.container['steel-chest'].circuit_connector[1])
lib.map_shifts(circuit, function(c) return {c[1] + 1.5, c[2] + 1.0} end)


---@type data.ProxyContainerPrototype
local space_platform_hub_connector = {
    type = 'proxy-container',
    name = 'kashmiras-platform-access',

    icon = '__kashmiras-big-beautiful-chests__/graphics/icons/platform-access.png',
    icon_size = 64,

    circuit_wire_max_distance = 9,

    circuit_connector = circuit,

    draw_inventory_content = false,

    selection_box = { { -2, -2 }, { 2, 2 } },
    collision_box = { { -1.7, -1.7 }, { 1.7, 1.7 } },

    surface_conditions = {
      { property = 'gravity', max = 0 }
    },

    subgroup = 'kashmiras-space-nonsense',
    order = 'a-a',

    picture = {
        layers = {
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/platform-access.png',
                width = 538,
                height = 532,
                shift = { 0, 0 },
                scale = 0.5,
            },
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/platform-access-shadow.png',
                width = 368,
                draw_as_shadow = true,
                height = 238,
                shift = { 0, 0 },
                scale = 0.5,
            }
        },
    }
    
}

---@type data.ItemPrototype
local space_platform_hub_connector_item = {


}