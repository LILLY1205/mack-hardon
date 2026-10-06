local RSGCore = exports['rsg-core']:GetCoreObject()

-- Prop settings
local PROP_MODEL = 'p_cs_sausage01x'
local OFFSET = { x = -0.18, y = 0.0, z = 0.07 }
local ROTATION = { pitch = 88.1, roll = 0.0, yaw = 0.0 }
local BONE_NAME = 'SKEL_Pelvis'
local BONE_NAME_ALT = 'CP_BeltFront'

-- Track active props per player
local activePlayers = {}

-- Server-side prop attachment
local function AttachPropToPlayer(src)
    if activePlayers[src] then return end
    activePlayers[src] = true
    
    -- Trigger all clients to see the prop
    TriggerClientEvent('mack-hardon:client:syncPropAttach', -1, src, PROP_MODEL, OFFSET, ROTATION, BONE_NAME, BONE_NAME_ALT)
    -- Tell the source client to start their local effect
    TriggerClientEvent('mack-hardon:client:applyEffect', src)
    
    -- Auto remove after duration
    SetTimeout(Config.HardonDuration, function()
        RemovePropFromPlayer(src)
    end)
end

function RemovePropFromPlayer(src)
    if not activePlayers[src] then return end
    activePlayers[src] = nil
    
    -- Trigger all clients to remove the prop
    TriggerClientEvent('mack-hardon:client:syncPropRemove', -1, src)
    TriggerClientEvent('mack-hardon:client:removeEffect', src)
end

-- Sync props for newly joined players
RegisterNetEvent('mack-hardon:server:requestSync', function()
    local src = source
    for playerId, _ in pairs(activePlayers) do
        TriggerClientEvent('mack-hardon:client:syncPropAttach', src, playerId, PROP_MODEL, OFFSET, ROTATION, BONE_NAME, BONE_NAME_ALT)
    end
end)

-- Auto hardon trigger from client (when near female NPC)
RegisterNetEvent('mack-hardon:server:triggerAutoHardon', function()
    local src = source
    AttachPropToPlayer(src)
end)

RSGCore.Functions.CreateUseableItem(Config.UseableItem, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Remove the item first
    if Player.Functions.RemoveItem(Config.UseableItem, 1) then
        -- Trigger inventory update
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.UseableItem], 'remove', 1)
        
        -- Apply the effect via server
        AttachPropToPlayer(src)
    else
        -- Player doesn't have the item
        TriggerClientEvent('bln_notify:send', src, {
            title = _L('no_item'),
            icon = 'star',
            placement = 'middle-right',
            duration = 3000
        })
    end
end)


-- Helper function to check if player is LEO
local function IsPlayerLeo(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return false end
    
    local job = Player.PlayerData.job
    if job and job.type == 'leo' then
        return true
    end
    return false
end

RegisterCommand('hardon', function(source, args, rawCommand)
    local src = source
    
    -- Check if player is LEO
    if not IsPlayerLeo(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = _L('no_permission'),
            icon = 'star',
            placement = 'middle-right',
            duration = 3000
        })
        return
    end
    
    local targetId = tonumber(args[1])
    
    if not targetId then
        return
    end
    
    local targetName = GetPlayerName(targetId)
    if not targetName then
        return
    end
    
    AttachPropToPlayer(targetId)
end, false)


RegisterCommand('removehardon', function(source, args, rawCommand)
    local src = source
    
    -- Check if player is LEO
    if not IsPlayerLeo(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = _L('no_permission'),
            icon = 'star',
            placement = 'middle-right',
            duration = 3000
        })
        return
    end
    
    local targetId = tonumber(args[1])
    
    if not targetId then
        return
    end
    
    local targetName = GetPlayerName(targetId)
    if not targetName then
        return
    end
    
    RemovePropFromPlayer(targetId)
end, false)


RegisterCommand('softie', function(source, args, rawCommand)
    local src = source
    
    -- Check if player is LEO
    if not IsPlayerLeo(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = _L('no_permission'),
            icon = 'star',
            placement = 'middle-right',
            duration = 3000
        })
        return
    end
    
    RemovePropFromPlayer(src)
end, false)

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    if activePlayers[src] then
        activePlayers[src] = nil
        TriggerClientEvent('mack-hardon:client:syncPropRemove', -1, src)
    end
end)
