---@diagnostic disable: need-check-nil

local extender = {}

local lib = require 'scripts.lib'

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
        radius = 2.245,
        name = { "kashmiras-big-chest", "kashmiras-big-extender" },
    }

    for i=#result,1,-1 do
        if 
            exclude_ids[result[i].unit_number]
            or result[i].unit_number == entity.unit_number
            or lib.manhattan_distance(result[i].position, entity.position) > 2.01
        then
            table.remove(result, i)
        end
    end

    return result
end

---@type fun(n:integer, ...:integer):integer
local quality_determiner = math.min

if settings.startup['kashmiras-big-extender-quality-determiner'] then
    quality_determiner = math[settings.startup['kashmiras-big-extender-quality-determiner'].value]
end

---@type integer
local max_link_distance = settings.startup['kashmiras-big-extender-distance'].value --[[@as integer]]

local quality_boost = 0

if settings.startup['kashmiras-big-extender-quality-boost'] then
    quality_boost = settings.startup['kashmiras-big-extender-quality-boost'].value --[[@as integer]]
end


---@param start_entity LuaEntity
---@param destroyed_id uint64?
---@param visited table<uint64, boolean>?
---@return LuaEntity[], LuaEntity[], uint32
local function map_out_chest_cluster(start_entity, destroyed_id, visited)
    local visited = visited or {} --[[@as table<uint64, boolean>]]
    local extenders = {}
    local chests = {}
    local queue = { start_entity }

    ---@type uint32
    local quality = lib.get_quality(start_entity)

    visited[start_entity.unit_number] = true
    if destroyed_id then
        visited[destroyed_id] = true
    end

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
            quality = quality_determiner(quality, lib.get_quality(neighbor))
            table.insert(queue, neighbor)
        end

        ::continue::
    end

    return extenders, chests, quality
end

---@param start_entity LuaEntity
---@param destroyed_id uint64?
local function link_cluster(start_entity, destroyed_id)
    local extenders, chests, quality = map_out_chest_cluster(start_entity, destroyed_id)

    local max_dist = quality * quality_boost + max_link_distance + 0.01

    for _, extender in pairs(extenders) do
        ---@type LuaEntity?
        local nearby_chest = nil
        local nearby_count = 0

        for _, chest in pairs(chests) do
            if lib.manhattan_distance(extender.position, chest.position) <= max_dist then
                nearby_count = nearby_count + 1
                nearby_chest = chest
            end
        end

        extender.proxy_target_entity = nil
        extender.proxy_target_inventory = defines.inventory.chest

        if nearby_count == 1 then
            extender.custom_status = nil
            extender.proxy_target_entity = nearby_chest
            lib.remove_blinker(extender)
        elseif nearby_count > 1 then
            extender.custom_status = overloaded_status
            lib.add_blinker(extender, 'utility.no_path_icon')
        elseif #chests > 0 then
            extender.custom_status = overextended_status
            lib.add_blinker(extender, 'utility.cargo_bay_too_far_from_source_icon')
        else
            extender.custom_status = unlinked_status
            lib.add_blinker(extender, 'utility.cargo_bay_not_connected_icon')
        end
    end
end

local names = {
    ["kashmiras-big-chest"] = true,
    ["kashmiras-big-extender"] = true,
}

---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_space_platform_mined_entity
function extender.on_built(event)
    if not names[event.entity.name] then return end
    link_cluster(event.entity)
end

---@param event EventData.on_entity_died|EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.script_raised_destroy|EventData.on_space_platform_built_entity
function extender.on_destroyed(event)
    if not names[event.entity.name] then return end
    local neighbors = neighbors_of(event.entity, { [event.entity.unit_number] = true })
    for _, neighbor in pairs(neighbors) do
        link_cluster(neighbor, event.entity.unit_number)
    end
end


extender.entity_filter = {
    { filter = "name", name = "kashmiras-big-chest" },
    { filter = "name", name = "kashmiras-big-extender" }
}

return extender