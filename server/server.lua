local QBCore = exports['qb-core']:GetCoreObject()

-- Give Wood
RegisterNetEvent('qb-lumberjack:server:GiveWood', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Random chance for rare wood
    local isRareWood = math.random(100) <= Config.RareWoodChance
    local woodItem = isRareWood and Config.RareWoodItem or Config.WoodItem
    
    -- Add wood to inventory
    Player.Functions.AddItem(woodItem, 5)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[woodItem], 'add')
end)

-- Sell Wood
RegisterNetEvent('qb-lumberjack:server:SellWood', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Check and sell normal wood
    local woodAmount = Player.Functions.GetItemByName(Config.WoodItem)
    if woodAmount and woodAmount.amount > 0 then
        local price = math.random(Config.WoodPrice.min, Config.WoodPrice.max)
        local totalPrice = price * woodAmount.amount
        Player.Functions.RemoveItem(Config.WoodItem, woodAmount.amount)
        Player.Functions.AddMoney('cash', totalPrice)
        TriggerClientEvent('QBCore:Notify', src, 'You sold ' .. woodAmount.amount .. ' wood for $' .. totalPrice)
    end

    -- Check and sell rare wood
    local rareWoodAmount = Player.Functions.GetItemByName(Config.RareWoodItem)
    if rareWoodAmount and rareWoodAmount.amount > 0 then
        local price = math.random(Config.RareWoodPrice.min, Config.RareWoodPrice.max)
        local totalPrice = price * rareWoodAmount.amount
        Player.Functions.RemoveItem(Config.RareWoodItem, rareWoodAmount.amount)
        Player.Functions.AddMoney('cash', totalPrice)
        TriggerClientEvent('QBCore:Notify', src, 'You sold ' .. rareWoodAmount.amount .. ' rare wood for $' .. totalPrice)
    end
end)

RegisterCommand('giveitem', function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local item = args[1] -- Nome do item
        local amount = tonumber(args[2]) or 1 -- Quantidade (padrão: 1)
        
        if item then
            if QBCore.Shared.Items[item] then
                Player.Functions.AddItem(item, amount)
                TriggerClientEvent('QBCore:Notify', src, 'Item recebido: ' .. item .. ' x' .. amount, 'success')
            else
                TriggerClientEvent('QBCore:Notify', src, 'Item inválido!', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Uso correto: /giveitem [item] [quantidade]', 'primary')
        end
    end
end, false)
