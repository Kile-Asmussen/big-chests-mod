---@diagnostic disable: need-check-nil

local constants = require 'scripts.constants'
local lib = require 'scripts.lib'
local util = require 'util'
local math2d = require 'math2d'


---@param a MapPosition.struct
---@param b MapPosition.struct
---@return number
---@overload fun(a:MapPosition,b:MapPosition):number
local function manhattan_distance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end

---@type CustomEntityStatus
local unlinked_status = { diode = defines.entity_status_diode.red, label = { 'entity-status.kashmiras-extender-unlinked' } }

---@type CustomEntityStatus
local overloaded_status = { diode = defines.entity_status_diode.yellow, label = { 'entity-status.kashmiras-extender-overloaded' } }

---@type CustomEntityStatus
local overextended_status = { diode = defines.entity_status_diode.yellow, label = { 'entity-status.kashmiras-extender-overextended' } }

---@param entity LuaEntity
---@param exclude_ids table<integer, boolean>?
---@return LuaEntity[]
local function neighbors_of(entity, exclude_ids)

    exclude_ids = exclude_ids or {}

    local result = entity.surface.find_entities_filtered{
        position = entity.position,
        radius = 2.01,
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

---@type fun(n:number, ...:number):number
local quality_determiner = math[settings.startup['kashmira-quality-distance'].value]

---@param start_entity LuaEntity
---@param destroyed_id uint64?
---@return LuaEntity[], LuaEntity[], uint32
local function flood_fill_chest_cluster(start_entity, destroyed_id)
    local visited = {}
    local extenders = {}
    local chests = {}
    local queue = { start_entity }

    ---@type uint32
    local quality = start_entity.quality.level

    visited[start_entity.unit_number] = true

    while #queue > 0 do
        local current = table.remove(queue)

        if current.unit_number == destroyed_id then
            goto continue
        end

        quality = math.min(quality, current.quality.level)

        if current.name == "kashmiras-big-extender" then
            table.insert(extenders, current)
        elseif current.name == "kashmiras-big-chest" then
            table.insert(chests, current)
        end

        for _, neighbor in pairs(neighbors_of(current, visited)) do
            visited[neighbor.unit_number] = true
            quality = quality_determiner(quality, neighbor.quality.level)
            table.insert(queue, neighbor)
        end

        ::continue::
    end

    return extenders, chests, quality
end

---@param start_entity LuaEntity
---@param destroyed_id uint64?
local function link_cluster(start_entity, destroyed_id)
    local extenders, chests, quality = flood_fill_chest_cluster(start_entity, destroyed_id)

    local max_dist = quality * constants.quality_distance_increase + constants.normal_link_distance + 0.01

    for _, extender in pairs(extenders) do
        ---@type LuaEntity?
        local nearby_chest = nil
        local nearby_count = 0

        for _, chest in pairs(chests) do
            if manhattan_distance(extender.position, chest.position) <= max_dist then
                nearby_count = nearby_count + 1
                nearby_chest = chest
            end
        end

        extender.proxy_target_entity = nil
        extender.proxy_target_inventory = nil

        if nearby_count == 1 then
            extender.custom_status = nil
            extender.proxy_target_entity = nearby_chest
            extender.proxy_target_inventory = defines.inventory.chest
            lib.remove_blinker(extender)
        elseif nearby_count > 1 then
            extender.custom_status = overloaded_status
            lib.add_blinker(extender, 'utility.no_path_icon')
        elseif nearby_count == 0 and #chests > 1 then
            extender.custom_status = overextended_status
            lib.add_blinker(extender, 'utility.cargo_bay_too_far_from_source_icon')
        else
            extender.custom_status = unlinked_status
            lib.add_blinker(extender, 'utility.cargo_bay_not_connected_icon')
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


local entity_filter = {
    { filter = "name", name = "kashmiras-big-chest" },
    {  filter = "name", name = "kashmiras-big-extender" }
}

script.on_event(defines.events.on_built_entity, on_built, entity_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, entity_filter)
script.on_event(defines.events.script_raised_built, on_built, entity_filter)
script.on_event(defines.events.script_raised_revive, on_built, entity_filter)

script.on_event(defines.events.on_entity_died, on_destroyed, entity_filter)
script.on_event(defines.events.on_player_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.script_raised_destroy, on_destroyed, entity_filter)