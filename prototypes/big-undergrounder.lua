---@diagnostic disable: need-check-nil

if mods['base'] < "2.1.21" then return end

local lib = require 'scripts.lib'

local big_undergrounder = table.deepcopy(data.raw['proxy-container']['kashmiras-big-extender'])

big_undergrounder.name = 'kashmiras-big-undergrounder'

big_undergrounder.direction_count = 4