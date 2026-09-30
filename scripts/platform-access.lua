---@diagnostic disable: need-check-nil

local lib = require 'scripts.lib'
local util = require 'util'

---@type CustomEntityStatus
local unlinked =
 { diode = defines.entity_status_diode.red, label = { 'entity-status.kashmiras-platform-access-unlinked' } }

 ---@type CustomEntityStatus
local overloaded =
 { diode = defines.entity_status_diode.yellow, label = { 'entity-status.kashmiras-platform-access-overloaded' } }

  ---@type CustomEntityStatus
local overextended =
 { diode = defines.entity_status_diode.yellow, label = { 'entity-status.kashmiras-platform-access-overextended' } }

---@type LuaPlatformBuiltEntityEventFilter[]
local entity_filter = {{
    filter = 'name',
    name = 'kashmiras-platform-access'
}}

---@type EntitySearchFilters
local space_platform_hub_filter = {
    type = 'space-platform-hub',
    limit = 1
}

---@type EntitySearchFilters
local platform_access_filter = {
    type = 'proxy-container',
    name = 'kashmiras-platform-access',
}

---@param event EventData.on_surface_deleted
local function cleanup(event)
    if storage.ports then
        storage.ports[event.surface_index] = nil
    end
end

---@type integer
local max_count = settings.startup['kashmiras-platform-access-count'].value --[[@as integer]]

local quality_boost = 0

if settings.startup['kashmiras-platform-access-quality-boost'] then
    quality_boost = settings.startup['kashmiras-platform-access-quality-boost'].value --[[@as integer]]
end

---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_space_platform_mined_entity
local function on_built(event)

    event.entity.proxy_target_entity = nil
    event.entity.proxy_target_inventory = defines.inventory.chest

    local space_platform = event.entity.surface.find_entities_filtered(space_platform_hub_filter)[1]

    if not space_platform then
        event.entity.custom_status = unlinked
        lib.add_blinker(event.entity, 'utility.cargo_bay_not_connected_icon')
        return
    end

    storage.ports = storage.ports or {} 
    storage.ports[event.entity.surface_index] = storage.ports[event.entity.surface_index] or {}

    ---@type table<integer, uint64[]>
    local all_ports = storage.ports[event.entity.surface_index]

    local this_quality = math.max(lib.get_quality(event.entity), lib.get_quality(space_platform))

    all_ports[this_quality] = all_ports[this_quality] or {}

    table.insert(all_ports[this_quality], event.entity.unit_number)

    local ports_of_lesser_quality = 0

    for quality, ports in pairs(all_ports) do
        if quality <= this_quality then
            ports_of_lesser_quality = ports_of_lesser_quality + #ports
        end
    end

    local max_ports = max_count + quality_boost * this_quality

    if ports_of_lesser_quality > max_ports then
        event.entity.custom_status = overloaded
        lib.add_blinker(event.entity, 'utility.no_path_icon')
    elseif
        lib.chebyshev_distance(event.entity.position, space_platform.position)
        > event.entity.force.max_cargo_bay_unloading_distance
    then
        event.entity.custom_status = overextended
        lib.add_blinker(event.entity, 'utility.cargo_bay_too_far_from_source_icon')
    else
        event.entity.custom_status = nil
        event.entity.proxy_target_entity = space_platform
        lib.remove_blinker(event.entity)
    end
end

---@param event EventData.on_entity_died|EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.script_raised_destroy|EventData.on_space_platform_built_entity
local function on_destroyed(event)

    if
        storage.ports
        and storage.ports[event.entity.surface_index]
        and storage.ports[event.entity.surface_index][lib.get_quality(event.entity)]
    then
        local ports = storage.ports[event.entity.surface_index][lib.get_quality(event.entity)] --[[@as uint64[] ]]

        util.remove_from_list(ports, event.entity.unit_number --[[@as uint64]])
    end

end

---@param entity LuaEntity?
---@return boolean
local function is_platform_access(entity)
    if not entity then return false end

    return entity.ghost_name == 'kashmiras-platform-access' or entity.name == 'kashmiras-platform-access'
end


---@param event EventData.on_selected_entity_changed
local function mouseover(event)

    storage.rectangles = storage.rectangles or {} 
    local rectangles = storage.rectangles --[[@as table<uint32, uint64>]]

    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    local is = is_platform_access(player.selected) 
    local hub = player.surface.find_entities_filtered(space_platform_hub_filter)[1]

    if rectangles[event.player_index] then
        local render = rendering.get_object_by_id(rectangles[event.player_index])
        if render then render.destroy() end
    end

    if not is then return end
    if not hub then return end

    local bonus = player.force.max_cargo_bay_unloading_distance

    local render = rendering.draw_rectangle{
        surface = player.surface_index,
        left_top = { hub.position.x - bonus, hub.position.y - bonus },
        right_bottom = { hub.position.x + bonus, hub.position.y + bonus },
        players = { event.player_index },
        draw_on_ground = true,
        filled = true,
        color = { 1, 1, 0, 0.5 },
    }

    rectangles[event.player_index] = render.id

end

script.on_event(defines.events.on_selected_entity_changed, mouseover)

script.on_event(defines.events.on_space_platform_built_entity, on_built, entity_filter)
script.on_event(defines.events.script_raised_built, on_built, entity_filter)
script.on_event(defines.events.script_raised_revive, on_built, entity_filter)

script.on_event(defines.events.on_space_platform_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.on_entity_died, on_destroyed, entity_filter)
script.on_event(defines.events.script_raised_destroy, on_destroyed, entity_filter)

-- these shouldn't happen but we include them anyway
script.on_event(defines.events.on_built_entity, on_built, entity_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, entity_filter)

script.on_event(defines.events.on_player_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed, entity_filter)

script.on_event(defines.events.on_surface_deleted, cleanup)