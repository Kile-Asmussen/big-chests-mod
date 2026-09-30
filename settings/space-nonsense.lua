
if not mods['space-age'] then return end

---@type data.ModIntSettingPrototype
local count = {
    type = 'int-setting',
    name = 'kashmiras-platform-access-count',
    setting_type = 'startup',
    default_value = 1,
    minimum_value = 1,
    order = 'b-a',
}
data:extend{count}

if mods['quality'] then

    ---@type data.ModIntSettingPrototype
    local boost = {
        type = 'int-setting',
        name = 'kashmiras-platform-access-quality-boost',
        setting_type = 'startup',
        default_value = 3,
        minimum_value = 1,
        order = 'b-a',
    }

    data:extend{boost}
end

---@type data.ModBoolSettingPrototype
local unlimited = {
    type = 'bool-setting',
    name = 'kashmiras-unlimited-landing-pads',
    default_value = true,
    setting_type = "startup",
    order = 'b-d'
}

data:extend{unlimited}