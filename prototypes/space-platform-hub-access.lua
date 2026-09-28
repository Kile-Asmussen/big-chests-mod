
if not mods['space-age'] then return end

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


---@type data.ProxyContainerPrototype
local space_platform_hub_connector = {
    type = 'proxy-container',
    name = 'kashmiras-platform-access',

    icon = '__kashmiras-big-beautiful-chests__/graphics/icons/platform-access.png',
    icon_size = 64,

    circuit_wire_max_distance = 9,


    draw_inventory_content = false,

    picture = {
        layers = {
            {
                filename = '__kashmiras-big-beautiful-chests__/graphics/platform-access.png',
                width = 538,
                height = 532,

            }
        }
    }
    
}