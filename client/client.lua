-- client/client.lua
local QBCore = exports['qb-core']:GetCoreObject()
local isChopping = false
local language = {}

-- Load Language File
local function LoadLanguage()
    local file = LoadResourceFile(GetCurrentResourceName(), 'config/languages/' .. Config.DefaultLanguage .. '.json')
    language = json.decode(file)
end

-- Create Blips
local function CreateBlips()
    for k, v in pairs(Config.Blips) do
        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip, v.sprite)
        SetBlipColour(blip, v.color)
        SetBlipScale(blip, v.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.label)
        EndTextCommandSetBlipName(blip)
    end
end

-- Check for Axe
local function HasAxe()
    return QBCore.Functions.HasItem(Config.AxeItem)
end

-- Chopping Animation
local function PlayChoppingAnimation()
    local ped = PlayerPedId()
    
    -- Carregar o dicionário de animação
    local dict = "melee@large_wpn@streamed_core"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
    
    -- Carregar o prop do machado
    local axeProp = CreateObject(GetHashKey("prop_tool_fireaxe"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(axeProp, ped, GetPedBoneIndex(ped, 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, false, false, false, 2, true)
    
    -- Iniciar animação em loop
    while isChopping do
        TaskPlayAnim(ped, dict, "ground_attack_on_spot", 8.0, -8.0, -1, 2, 0, false, false, false)
        Wait(2700) -- Aguarda a animação terminar antes de repetir
    end
    
    -- Limpar
    DeleteObject(axeProp)
    RemoveAnimDict(dict)
end

-- Stop Chopping Animation
local function StopChoppingAnimation()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
    
    -- Remover qualquer prop que possa estar anexado
    local axeProp = GetClosestObjectOfType(GetEntityCoords(ped), 2.0, GetHashKey("prop_tool_fireaxe"), false, false, false)
    if DoesEntityExist(axeProp) then
        DeleteObject(axeProp)
    end
end

-- Stop Work Function
local function StopWork()
    isChopping = false
    StopChoppingAnimation()
    QBCore.Functions.Notify(language.stopped_working, 'primary')
end

-- Start Chopping
local function StartChopping()
    if isChopping then return end
    if not HasAxe() then
        QBCore.Functions.Notify(language.need_axe, 'error')
        return
    end

    isChopping = true
    QBCore.Functions.Notify(language.press_x_stop, 'primary', 5000)
    
    -- Iniciar thread da animação
    CreateThread(function()
        PlayChoppingAnimation()
    end)

    -- Thread para o trabalho
    CreateThread(function()
        while isChopping do
            if not isChopping then break end
            Wait(5000)
            TriggerServerEvent('qb-lumberjack:server:GiveWood')
        end
    end)

    -- Thread para verificar a tecla X
    CreateThread(function()
        while true do
            Wait(0)
            if not isChopping then break end
            
            if IsControlJustReleased(0, 73) then -- 73 é o código da tecla X
                StopWork()
                break
            end
        end
    end)
end

-- Initialize
CreateThread(function()
    LoadLanguage()
    CreateBlips()

    -- Tree Location
    exports['qb-target']:AddCircleZone("tree_cutting", Config.TreeLocation.coords, Config.TreeLocation.radius, {
        name = "tree_cutting",
        debugPoly = Config.Debug,
    }, {
        options = {
            {
                type = "client",
                event = "qb-lumberjack:client:StartChopping",
                icon = "fas fa-tree",
                label = language.start_chopping,
            },
        },
        distance = 2.5
    })

    -- Sell Location
    exports['qb-target']:AddCircleZone("wood_selling", Config.SellLocation.coords, Config.SellLocation.radius, {
        name = "wood_selling",
        debugPoly = Config.Debug,
    }, {
        options = {
            {
                type = "client",
                event = "qb-lumberjack:client:SellWood",
                icon = "fas fa-dollar-sign",
                label = language.sell_wood,
            },
        },
        distance = 2.5
    })
end)

-- Events
RegisterNetEvent('qb-lumberjack:client:StartChopping', function()
    StartChopping()
end)

RegisterNetEvent('qb-lumberjack:client:StopChopping', function()
    StopWork()
end)

RegisterNetEvent('qb-lumberjack:client:SellWood', function()
    TriggerServerEvent('qb-lumberjack:server:SellWood')
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isChopping then
            StopWork()
        end
    end
end)

-- Garantir que o trabalho pare se o jogador morrer
AddEventHandler('baseevents:onPlayerDied', function()
    if isChopping then
        StopWork()
    end
end)

-- Garantir que o trabalho pare se o jogador for revivido
AddEventHandler('baseevents:onPlayerWasted', function()
    if isChopping then
        StopWork()
    end
end)

-- Garantir que o trabalho pare se o jogador entrar em um veículo
CreateThread(function()
    while true do
        Wait(1000)
        if isChopping then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                StopWork()
            end
        end
    end
end)