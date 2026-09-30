    
---@type data.ModIntSettingPrototype
local distance = {
    type = 'int-setting',
    name = 'kashmiras-extender-distance',
    setting_type = 'startup',
    default_value = 10,
    minimum_value = 2,
    order = 'b',
}

data:extend{distance}

if mods['quality'] then
    ---@type data.ModIntSettingPrototype
    local boost = {
        type = 'int-setting',
        name = 'kashmiras-quality-boost',
        setting_type = 'startup',
        default_value = 2,
        minimum_value = 1,
        order = 'a',
    }

        ---@type data.ModStringSettingPrototype
    local min_max = {
        type = 'string-setting',
        name = 'kashmiras-quality-distance',
        setting_type = 'startup',
        default_value = 'min',
        allowed_values = { 'min', 'max' },
        order = 'c',
    }

    data:extend{min_max, boost}
end