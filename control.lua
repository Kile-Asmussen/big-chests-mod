
local extender = require 'scripts.extender'
local access = require 'scripts.platform-access'
local util = require 'util'

local entity_filter = table.deepcopy(extender.entity_filter)
for _, f in pairs(access.entity_filter) do table.insert(entity_filter, f) end

local function on_built(event)
    extender.on_built(event)
    access.on_built(event)
end

local function on_destroyed(event)
    extender.on_destroyed(event)
    access.on_destroyed(event)
end

script.on_event(defines.events.on_built_entity, on_built, entity_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, entity_filter)
script.on_event(defines.events.on_space_platform_built_entity, on_built, entity_filter)
script.on_event(defines.events.script_raised_built, on_built, entity_filter)
script.on_event(defines.events.script_raised_revive, on_built, entity_filter)

script.on_event(defines.events.on_entity_died, on_destroyed, entity_filter)
script.on_event(defines.events.on_player_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.on_space_platform_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed, entity_filter)
script.on_event(defines.events.script_raised_destroy, on_destroyed, entity_filter)



script.on_event(defines.events.on_selected_entity_changed, access.mouseover)
script.on_event(defines.events.on_surface_deleted, access.surface_cleanup)