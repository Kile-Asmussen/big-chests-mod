
---@type data.ItemSubGroup
local kashmiras_big_beautiful_chests = {
    type = 'item-subgroup',
    name = 'kashmiras-big-beautiful-chests',
    group = 'logistics',
    order = data.raw['item-subgroup'].storage.order .. '-z'
}

data:extend{kashmiras_big_beautiful_chests}

if mods['space-age'] then

    local kashmiras_space_nonsense = {
        type = 'item-subgroup',
        name = 'kashmiras-space-nonsense',
        group = 'space',
        order = data.raw['item-subgroup'].storage.order .. '-z'
    }

    data:extend{kashmiras_space_nonsense}

end
