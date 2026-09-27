---@diagnostic disable: duplicate-type

local math2d = require 'math2d'
local util = require 'util'

local lib = {}

---@alias GraphicsThingy data.CraftingMachineGraphicsSet|data.Animation4Way|data.WaterReflectionDefinition|data.Sprite|data.Sprite|data.SpriteVariations|data.Sprite4Way|data.SpriteSheet|data.SpriteNWaySheet|data.SpriteVariations|data.WorkingVisualisation|data.RotatedAnimation|GraphicsThingy[]

---@param animation GraphicsThingy|nil
---@param scale number
function lib.set_scale(animation, scale)

    if not animation then return end

    if animation.scale then animation.scale = animation.scale * scale end
    if animation.shift then animation.shift = math2d.position.multiply_scalar(animation.shift --[[@as Vector]], scale) --[[@as data.Vector.struct]] end

    if #animation > 0 then
        for i=1,#animation do
            lib.set_scale(animation[i], scale)
        end
    end

    lib.set_scale(animation.water_reflection, scale)
    lib.set_scale(animation.working_visualisations, scale)
    lib.set_scale(animation.frozen_patch, scale)
    lib.set_scale(animation.layers, scale)
    lib.set_scale(animation.pictures, scale)
    lib.set_scale(animation.sheet, scale)
    lib.set_scale(animation.animation, scale)

    for _, dir in pairs{'north', 'south', 'east', 'west', 'north_east', 'north_west', 'south_east', 'south_west'} do
        lib.set_scale(animation[dir], scale)
    end
end

---@alias CircuitThingy data.CircuitConnectorDefinition|data.CircuitConnectorSprites|data.WireConnectionPoint|data.CircuitConnectorSprites|data.Sprite|[double,double]

---@param circuit CircuitThingy|CircuitThingy[]|nil
---@param fn fun(sh:[double,double]):[double,double]
function lib.map_shifts(circuit, fn)

    if not circuit then return end
    if type(circuit) ~= 'table' then return end

    if table_size(circuit) == 2 and #circuit == 2 and type(circuit[1]) == 'number' and type(circuit[2]) == 'number' then
        ---@cast circuit [double,double]
        local res = fn(circuit)
        circuit[1] = res[1]
        circuit[2] = res[2]
        return
    end

    for k, v in pairs(circuit) do
        lib.map_shifts(v, fn)
    end

end

--- Appeasing the type checker
---@generic T
---@param tbl T[]?
---@param val T
function lib.insert(tbl, val)
    tbl --[[@as T[] ]] [#tbl+1]=val
end

---@generic T
---@param tbl T[]?
---@param len integer
function lib.cut(tbl, len)
    while #tbl > len do
        tbl --[[@as T[] ]][#tbl] = nil
    end
end


---@param recipes { category: (data.RecipeCategoryID|data.RecipeCategoryID[]), replace?: (data.RecipeCategoryID|fun(data.RecipeCategoryID):boolean), [number]:data.RecipeID }
function lib.add_recipe_category(recipes)

    local category = recipes.category
    local replace = recipes.replace

    recipes.category = nil
    recipes.replace = nil
    ---@cast recipes data.RecipeID[]

    if type(category) ~= 'table' then
        category = { category }
        ---@cast category data.RecipeCategoryID[]
    end
    
    if type(replace) ~= 'function' then
        replace = function(s) return s == replace end
    end

    for _, recipe_id in pairs(recipes) do
        
        local recipe = data.raw.recipe[recipe_id]

        if not recipe then
            error("no such recipe " .. recipe_id)
        end

        if not recipe.categories then
            recipe.categories = {"crafting"}
        end

        for i=#recipe.categories,1,-1 do
            if replace(recipe.categories[i]) then
                table.remove(recipe.categories, i)
            end
        end

        for i=1,#category do
            table.insert(recipe.categories, category[i])
        end
    end
end

return lib