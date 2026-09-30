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

    circuit_connector = nil,

    draw_inventory_content = false,

    picture = {
        layers = {
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/platform-access.png',
                width = 538,
                height = 532,
                shift = { 0, 0 },
                scale = 0.5,

            }
        }
    }
    
}

--[[
    {
      "filename": "__base__/graphics/entity/linked-chest/linked-chest.png",
      "priority": "extra-high",
      "width": 66,
      "height": 74,
      "shift": [
        0,
        -0.0625
      ],
      "scale": 0.5,
      "tint": [
        0.8,
        0.1,
        0.3
      ]
    },
    {
      "filename": "__base__/graphics/entity/linked-chest/linked-chest-shadow.png",
      "priority": "extra-high",
      "width": 112,
      "height": 46,
      "shift": [
        0.375,
        0.140625
      ],
      "draw_as_shadow": true,
      "scale": 0.5,
      "tint": [
        0.8,
        0.1,
        0.3
      ]
    }

]]