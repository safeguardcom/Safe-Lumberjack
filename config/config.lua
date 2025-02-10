Config = {}
Config.Debug = false
Config.DefaultLanguage = 'pt'
----------------------------------
--------------ITEMS---------------
----------------------------------
Config.AxeItem = 'hatchet'
Config.WoodItem = 'wood'
Config.RareWoodItem = 'rare_wood'
----------------------------------
----------------------------------
----------------------------------
Config.RareWoodChance = 50 -- 15% chance for rare wood
Config.WoodPrice = {
    min = 200,
    max = 300
}
Config.RareWoodPrice = {
    min = 300,
    max = 600
}
Config.TreeLocation = {
    coords = vector3(-565.73, 5502.18, 57.97),
    radius = 50.0
}

Config.SellLocation = {
    coords = vector3(-565.46, 5325.57, 73.61),
    radius = 2.0
}
Config.Blips = {
    ['tree_location'] = {
        coords = vector3(-565.73, 5502.18, 57.97),
        sprite = 477,
        color = 2,
        scale = 0.8,
        label = "Lumberjack - Tree Cutting"
    },
    ['sell_location'] = {
        coords = vector3(-565.46, 5325.57, 73.61),
        sprite = 365,
        color = 2,
        scale = 0.8,
        label = "Lumberjack - Wood Selling"
    }
}