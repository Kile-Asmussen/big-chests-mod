
if not settings.startup['kashmiras-unlimited-landing-pads'] then return end

if not settings.startup['kashmiras-unlimited-landing-pads'].value then return end

local lib = require 'scripts.lib'

---@type data.CargoLandingPadLimitModifier
local unlimited = {
    type = 'cargo-landing-pad-count',
    modifier = 9999,
    hidden = true
}

lib.insert(data.raw.technology['rocket-silo'].effects,
    unlimited --[[@as data.Modifier]]
)