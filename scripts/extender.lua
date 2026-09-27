---@diagnostic disable: need-check-nil

local constants = require 'scripts.constants'
local util = require 'util'
local math2d = require 'math2d'

local entity_filter = {
    { filter = "name", name = "kashmiras-big-chest" },
    { filter = "name", name = "kashmiras-big-extender" }
}

---@param a MapPosition.struct
---@param b MapPosition.struct
---@return number
---@overload fun(a:MapPosition,b:MapPosition):number
local function manhattan_distance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end

---@param entity LuaEntity
---@param exclude_ids table<integer, boolean>?
---@return LuaEntity[]
local function neighbors_of(entity, exclude_ids)

    exclude_ids = exclude_ids or {}

    local result = entity.surface.find_entities_filtered{
        position = entity.position,
        radius = 1.51,
        name = { "kashmiras-big-chest", "kashmiras-big-extender" },
    }

    for i=#result,1,-1 do
        if 
            exclude_ids[result[i].unit_number]
            or result[i].unit_number == entity.unit_number
            or manhattan_distance(result[i].position, entity.position) > 2
        then
            table.remove(result, i)
        end
    end

    return result
end

---@param start_entity LuaEntity
---@param destroyed_id uint64?
---@return LuaEntity[], LuaEntity[], uint32
local function flood_fill_chest_cluster(start_entity, destroyed_id)
    local visited = {}
    local extenders = {}
    local chests = {}
    local queue = { start_entity }

    ---@type uint32
    local min_quality = start_entity.quality.level

    visited[start_entity.unit_number] = true

    while #queue > 0 do
        local current = table.remove(queue)

        if current.unit_number == destroyed_id then
            goto continue
        end

        min_quality = math.min(min_quality, current.quality.level)

        if current.name == "kashmiras-big-extender" then
            table.insert(extenders, current)
        elseif current.name == "kashmiras-big-chest" then
            table.insert(chests, current)
        end

        for _, neighbor in pairs(neighbors_of(current, visited)) do
            visited[neighbor.unit_number] = true
            min_quality =  math.min( min_quality, neighbor.quality.level)
            table.insert(queue, neighbor)
        end

        ::continue::
    end

    return extenders, chests, min_quality
end

---@type CustomEntityStatus
local not_linked_status = { diode = defines.entity_status_diode.red, label = { 'entity-status.kashmiras-extender-unlinked' } }

---@param entity LuaEntity
local function add_blinker(entity)
    storage.blinkers = storage.blinkers or {}
    if storage.blinkers[entity.unit_number] then return end

    local render = rendering.draw_sprite{
        sprite = "utility.cargo_bay_not_connected_icon",
        x_scale = 0.5,
        y_scale = 0.5,
        surface = entity.surface,
        target = entity,
        blink_interval = 30,
        sprite_param = {},
        draw_sprite_param = {},
        render_layer = "entity-info-icon"
    }
    storage.blinkers[entity.unit_number] = render.id
end

---@param entity LuaEntity
local function remove_blinker(entity)
    storage.blinkers = storage.blinkers or {}
    if storage.blinkers[entity.unit_number] then
        local render = rendering.get_object_by_id(storage.blinkers[entity.unit_number])
        if render then render.destroy() end
        storage.blinkers[entity.unit_number] = nil
    end
end

---@param start_entity LuaEntity
---@param destroyed_id uint64?
local function link_cluster(start_entity, destroyed_id)
    local extenders, chests, min_quality = flood_fill_chest_cluster(start_entity, destroyed_id)

    local max_dist = min_quality * constants.quality_distance_increase + constants.normal_link_distance + 0.01

    for _, extender in pairs(extenders) do
        local nearby_chest = nil
        local nearby_count = 0

        for _, chest in pairs(chests) do
            if manhattan_distance(extender.position, chest.position) <= max_dist then
                nearby_count = nearby_count + 1
                nearby_chest = chest
            end
        end

        if nearby_count == 1 then
            extender.custom_status = nil
            extender.proxy_target_entity = nearby_chest
            remove_blinker(extender)
        else
            extender.custom_status = not_linked_status
            extender.proxy_target_entity = nil
            add_blinker(extender)
        end
    end
end

---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive
local function on_built(event)
    link_cluster(event.entity)
end

---@param event EventData.on_entity_died|EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.script_raised_destroy
local function on_destroyed(event)
    link_cluster(event.entity, event.entity.unit_number)
end

script.on_event(defines.events.on_built_entity, on_built, entity_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, entity_filter)
script.on_event(defines.events.script_raised_built, on_built, entity_filter)
script.on_event(defines.events.script_raised_revive, on_built, entity_filter)

script.on_event(defines.events.on_entity_died, on_destroyed, entity_filter)
script.on_event(defines.events.on_player_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.script_raised_destroy, on_destroyed, entity_filter)