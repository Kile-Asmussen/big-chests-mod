if mods['base'] < "2.1.21" then return end

---@type data.ModIntSettingPrototype
local distance = {
    type = 'int-setting',
    name = 'kashmiras-big-undergrounder-distance',
    setting_type = 'startup',
    default_value = 2,
    minimum_value = 1,
    order = 'c-a',
}

data:extend{distance}

if mods['quality'] then
    ---@type data.ModIntSettingPrototype
    local boost = {
        type = 'int-setting',
        name = 'kashmiras-big-undergrounder-quality-boost',
        setting_type = 'startup',
        default_value = 1,
        minimum_value = 0,
        order = 'c-b',
    }

        ---@type data.ModBoolSettingPrototype
    local hits = {
        type = 'string-setting',
        name = 'kashmiras-big-undergrounder-hits-extenders',
        setting_type = 'startup',
        default_value = false,
        order = 'c-c',
    }

    data:extend{hits, boost}
end