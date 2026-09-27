
if mods['quality'] then
    ---@type data.ModStringSettingPrototype
    local min_max = {
        type = 'string-setting',
        name = 'kashmira-quality-distance',
        setting_type = 'startup',
        default_value = 'min',
        allowed_values = { 'min', 'max' }
    }

    data:extend{min_max}
end