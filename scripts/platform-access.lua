
---@type LuaPlatformBuiltEntityEventFilter[]
local entity_filter = {{
    filter = 'name',
    name = 'kashmiras-platform-access'
}}

---@type EntitySearchFilters
local space_platform_hub_filter = {
    type = ''
}

---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_space_platform_mined_entity
local function on_built(event)
    event.entity.surface.find_entities_filtered(entity_filter[1] --[[@as EntitySearchFilters]])
end

script.on_event(defines.events.on_space_platform_built_entity, on_built, entity_filter)

-- these shouldn't happen but we include them anyway
script.on_event(defines.events.on_built_entity, on_built, entity_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, entity_filter)
script.on_event(defines.events.script_raised_built, on_built, entity_filter)
script.on_event(defines.events.script_raised_revive, on_built, entity_filter)