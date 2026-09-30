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

---@param index integer
---@param access LuaEntity
---@param hub LuaEntity?
local function link(index, access, hub)
    access.proxy_target_entity = nil
    access.proxy_target_inventory = defines.inventory.chest

    if not hub then
        access.custom_status = unlinked
        lib.add_blinker(access, 'utility.cargo_bay_not_connected_icon')
        return
    elseif
        lib.chebyshev_distance(access.position, hub.position)
        > access.force.max_cargo_bay_unloading_distance
    then
        access.custom_status = overextended
        lib.add_blinker(access, 'utility.cargo_bay_too_far_from_source_icon')
        return
    end

    local relevant_quality = math.max(access.quality.level, hub.quality.level)
    local max_ports = max_count + relevant_quality * quality_boost


    if index > max_ports then
        access.custom_status = overloaded
        lib.add_blinker(access, 'utility.no_path_icon')
    else
        access.custom_status = nil
        access.proxy_target_entity = hub
        lib.remove_blinker(access)
    end
end

---@param surface LuaSurface
---@param dead uint64?
local function re_link_all(surface, dead)

    local ports = surface.find_entities_filtered(platform_access_filter)

    if dead then
        for i, port in pairs(ports) do
            if port.unit_number == dead then table.remove(ports, i) break end
        end
    end

    local hub = surface.find_entities_filtered(space_platform_hub_filter)[1]

    if not hub then
        for _, port in pairs(ports) do
            link(0, port, nil)
        end
    end

    table.sort(ports, function(ent1, ent2)
        local q1 = lib.get_quality(ent1)
        local q2 = lib.get_quality(ent2)

        return q1 < q2 or (q1 == q2 and ent1.unit_number < ent2.unit_number) or false
    end)

    for i = 1,#ports do
        link(i, ports[i], hub)
    end
end

---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_space_platform_mined_entity
local function on_built(event)

    re_link_all(event.entity.surface)

end

---@param event EventData.on_entity_died|EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.script_raised_destroy|EventData.on_space_platform_built_entity
local function on_destroyed(event)

    re_link_all(event.entity.surface, event.entity.unit_number)

end



---@param event EventData.on_selected_entity_changed
local function mouseover(event)

    storage.rectangles = storage.rectangles or {} 
    local rectangles = storage.rectangles --[[@as table<uint32, uint64>]]

    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    local is = player.selected and player.selected.name == 'kashmiras-platform-access' or false
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
        color = { r=0.2, g=0.2, b=0.1, a=0.3 },
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