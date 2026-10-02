---@diagnostic disable: need-check-nil

if mods['base'] < "2.1.21" then return end

local lib = require 'scripts.lib'

---@type data.ProxyContainerPrototype
local big_undergrounder = table.deepcopy(data.raw.container['kashmiras-big-chest']) --[[@as data.ProxyContainerPrototype]]

big_undergrounder.name = 'kashmiras-big-undergrounder'
big_undergrounder.type = 'proxy-container'

big_undergrounder.