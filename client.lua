local effectActive = false
local excitedCooldown = false
local reactedPeds = {}
local autoDetectionActive = false
local femaleReacting = false

-- Track synced props from other players
local syncedProps = {}


local function IsPedFemale(ped)
    if not DoesEntityExist(ped) then return false end
    local isMale = IsPedMale(ped)
    return (isMale == 0 or isMale == false)
end


local function HasPedReacted(ped)
    return reactedPeds[ped] == true
end


local function MarkPedReacted(ped)
    reactedPeds[ped] = true
    SetTimeout(Config.NpcReactionCooldown, function()
        reactedPeds[ped] = nil
    end)
end


local function GetFleeCoords(pedCoords, playerCoords, fleeDistance)
    local heading = GetHeadingFromVector_2d(pedCoords.x - playerCoords.x, pedCoords.y - playerCoords.y)
    local rad = math.rad(heading)
    
    local fleeX = pedCoords.x + (math.sin(rad) * fleeDistance)
    local fleeY = pedCoords.y + (math.cos(rad) * fleeDistance)
    
    local _, fleeZ = GetGroundZFor_3dCoord(fleeX, fleeY, pedCoords.z + 100.0, true)
    
    return vector3(fleeX, fleeY, fleeZ or pedCoords.z)
end


local function MakeFemaleFollow(npcPed)
    local followChance = math.random(1, 100)
    if followChance > Config.FemaleFollowChance then 
        femaleReacting = false 
        return 
    end
    
    Wait(7000)
    
    if not DoesEntityExist(npcPed) then 
        femaleReacting = false
        return 
    end
    if not effectActive then 
        femaleReacting = false
        return 
    end
    
    ClearPedTasks(npcPed)
    
    Wait(500)
    
    TriggerEvent('bln_notify:send', {
        title = _LRandom('following', 5),
        icon = 'star',
        placement = 'middle-right',
        duration = 4000
    })
    
    local playerPed = PlayerPedId()
    
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    TaskFollowToOffsetOfEntity(npcPed, playerPed, 0.0, -1.5, 0.0, 1.0, -1, 1.5, true, false, false, false, false, false)
    
    SetTimeout(Config.FemaleFollowDuration, function()
        if DoesEntityExist(npcPed) then
            ClearPedTasks(npcPed)
            SetBlockingOfNonTemporaryEvents(npcPed, false)
            
            TriggerEvent('bln_notify:send', {
                title = _LRandom('stop_following', 5),
                icon = 'star',
                placement = 'middle-right',
                duration = 4000
            })
        end
        
        femaleReacting = false
    end)
end

-- Function to make male NPC react and flee
local function MakeMaleReact(npcPed, playerPed, playerCoords)
    if HasPedReacted(npcPed) then return end
    MarkPedReacted(npcPed)
    
    ClearPedTasksImmediately(npcPed)
    
    TriggerEvent('bln_notify:send', {
        title = _L('man_horrified'),
        icon = 'star',
        placement = 'middle-right',
        duration = 3000
    })
    
    Wait(500)
    
    TriggerEvent('bln_notify:send', {
        title = _LRandom('male_reaction', 7),
        icon = 'star',
        placement = 'middle-right',
        duration = 4000
    })
    
    local npcCoords = GetEntityCoords(npcPed)
    local fleeCoords = GetFleeCoords(npcCoords, playerCoords, 50.0)
    
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    SetPedFleeAttributes(npcPed, 0, false)
    SetPedCombatAttributes(npcPed, 17, true)
    
    SetPedDesiredMoveBlendRatio(npcPed, 10.0)
    SetPedMoveRateOverride(npcPed, 1.5)
    
    
    
    SetTimeout(15000, function()
        if DoesEntityExist(npcPed) then
            SetBlockingOfNonTemporaryEvents(npcPed, false)
            SetPedDesiredMoveBlendRatio(npcPed, 1.0)
            SetPedMoveRateOverride(npcPed, 1.0)
            ClearPedTasks(npcPed)
        end
    end)
end


local function MakeFemaleReact(npcPed, playerPed)
    if HasPedReacted(npcPed) then return end
    if femaleReacting then return end 
    
    femaleReacting = true 
    MarkPedReacted(npcPed)
    
    TriggerEvent('bln_notify:send', {
        title = _LRandom('excited', 5),
        icon = 'star',
        placement = 'middle-right',
        duration = 3000
    })
    
    Wait(1000)
    
    ClearPedTasks(npcPed)
    ClearPedTasksImmediately(npcPed)
    
    Wait(100)
    
    TaskTurnPedToFaceEntity(npcPed, playerPed, 2000)
    Wait(2000)
    
    TaskStartScenarioInPlace(npcPed, joaat('WORLD_HUMAN_CROUCH_INSPECT'), 7000, true, false, false, false)
    
    TriggerEvent('bln_notify:send', {
        title = _L('woman_cant_believe'),
        icon = 'star',
        placement = 'middle-right',
        duration = 3000
    })
    
    Wait(2000)
    
    TriggerEvent('bln_notify:send', {
        title = _LRandom('female_reaction', 5),
        icon = 'star',
        placement = 'middle-right',
        duration = 4000
    })
    
    CreateThread(function()
        MakeFemaleFollow(npcPed)
    end)
end


local function StartNpcReactionDetection()
    if autoDetectionActive then return end
    autoDetectionActive = true
    
    CreateThread(function()
        
        
        while effectActive do
            Wait(2000)
            
            if not effectActive then break end
            
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            local handle, ped = FindFirstPed()
            local success
            
            repeat
                if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not HasPedReacted(ped) then
                    local pedCoords = GetEntityCoords(ped)
                    local distance = #(playerCoords - pedCoords)
                    
                    if distance < Config.NpcReactionDistance and distance > 1.0 then
                        local isFemale = IsPedFemale(ped)
                        
                        if isFemale then
                           
                            if not femaleReacting then
                               
                                CreateThread(function()
                                    MakeFemaleReact(ped, playerPed)
                                end)
                                Wait(3000)
                            end
                        else
                            
                            --CreateThread(function()
                                --MakeMaleReact(ped, playerPed, playerCoords)
                            --end)
                            --Wait(3000)
                        end
                    end
                end
                
                success, ped = FindNextPed(handle)
            until not success
            
            EndFindPed(handle)
        end
        
        autoDetectionActive = false
        
    end)
end

-- Attach prop to a specific player ped (synced from server)
local function AttachPropToPlayerPed(playerId, propModel, offset, rotation, boneName, boneNameAlt)
    local targetPed = nil
    local myServerId = GetPlayerServerId(PlayerId())
    
    -- Check if this is for the local player
    if playerId == myServerId then
        targetPed = PlayerPedId()
    else
        local playerIndex = GetPlayerFromServerId(playerId)
        if playerIndex ~= -1 then
            targetPed = GetPlayerPed(playerIndex)
        end
    end
    
    if not targetPed or not DoesEntityExist(targetPed) then return end
    
    -- Remove existing prop if any
    if syncedProps[playerId] and DoesEntityExist(syncedProps[playerId]) then
        DeleteEntity(syncedProps[playerId])
    end
    
    local propHash = GetHashKey(propModel)
    RequestModel(propHash)
    local timeout = 0
    while not HasModelLoaded(propHash) do
        Wait(100)
        timeout = timeout + 100
        if timeout > 5000 then return end
    end
    
    -- Try alternative bone first, then primary, then pelvis as last resort
    local boneIndex = -1
    if boneNameAlt then
        boneIndex = GetEntityBoneIndexByName(targetPed, boneNameAlt)
    end
    if boneIndex == -1 and boneName then
        boneIndex = GetEntityBoneIndexByName(targetPed, boneName)
    end
    if boneIndex == -1 then
        boneIndex = GetEntityBoneIndexByName(targetPed, "SKEL_Pelvis")
    end
    if boneIndex == -1 then
        boneIndex = 0 -- Use root bone as absolute fallback
    end
    
    local coords = GetEntityCoords(targetPed)
    local prop = CreateObject(propHash, coords.x, coords.y, coords.z, true, true, false)
    
    if not DoesEntityExist(prop) then return end
    
    AttachEntityToEntity(
        prop,
        targetPed,
        boneIndex,
        offset.x,
        offset.y,
        offset.z,
        rotation.pitch,
        rotation.roll,
        rotation.yaw,
        false,
        false,
        false,
        false,
        2,
        true
    )
    
    SetModelAsNoLongerNeeded(propHash)
    syncedProps[playerId] = prop
end

-- Remove prop from a specific player
local function RemovePropFromPlayerPed(playerId)
    if syncedProps[playerId] and DoesEntityExist(syncedProps[playerId]) then
        DeleteEntity(syncedProps[playerId])
        syncedProps[playerId] = nil
    end
end

-- Handle synced prop attachment from server
RegisterNetEvent('mack-hardon:client:syncPropAttach', function(playerId, propModel, offset, rotation, boneName, boneNameAlt)
    CreateThread(function()
        AttachPropToPlayerPed(playerId, propModel, offset, rotation, boneName, boneNameAlt)
    end)
end)

-- Handle synced prop removal from server
RegisterNetEvent('mack-hardon:client:syncPropRemove', function(playerId)
    RemovePropFromPlayerPed(playerId)
end)

-- Local effect activation (for NPC detection, notifications)
local function ActivateLocalEffect()
    if effectActive then return end
    
    effectActive = true
    excitedCooldown = false
    reactedPeds = {}
    femaleReacting = false
    
    TriggerEvent('bln_notify:send', {
        title = _L('aroused_no_reason'),
        icon = 'star',
        placement = 'middle-right',
        duration = 5000
    })
    
    StartNpcReactionDetection()
end

local function DeactivateLocalEffect()
    effectActive = false
    excitedCooldown = false
    reactedPeds = {}
    femaleReacting = false
end

-- Request sync on resource start
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('mack-hardon:server:requestSync')
end)


CreateThread(function()
    while true do
        Wait(2000)
        
        if not Config.AutoHardonEnabled then
            goto continue
        end
        
        if effectActive then
            goto continue
        end
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        local handle, ped = FindFirstPed()
        local success
        
        repeat
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance < Config.AutoDetectionDistance and distance > 1.0 then
                    local isFemale = IsPedFemale(ped)
                    
                    if isFemale then
                        TriggerEvent('bln_notify:send', {
                            title = _LRandom('hardon_trigger', 5),
                            icon = 'star',
                            placement = 'middle-right',
                            duration = 4000
                        })
                        
                        Wait(1000)
                        
                        -- Request server to attach prop
                        TriggerServerEvent('mack-hardon:server:triggerAutoHardon')
                        
                        break
                    end
                end
            end
            
            success, ped = FindNextPed(handle)
        until not success
        
        EndFindPed(handle)
        
        ::continue::
    end
end)

-- Setup ox_target for NPCs (MANUAL TRIGGER)
CreateThread(function()
    exports.ox_target:addGlobalPed({
        {
            name = 'hardon_show_off',
            icon = 'fa-solid fa-eye',
            label = _L('show_off_label'),
            canInteract = function(entity, distance, coords, name)
                return effectActive and not IsPedAPlayer(entity) and not HasPedReacted(entity)
            end,
            onSelect = function(data)
                CreateThread(function()
                    local ped = data.entity
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    
                    if IsPedFemale(ped) then
                        if femaleReacting then
                            TriggerEvent('bln_notify:send', {
                                title = _L('someone_else_attention'),
                                icon = 'star',
                                placement = 'middle-right',
                                duration = 3000
                            })
                            return
                        end
                        MakeFemaleReact(ped, playerPed)
                    else
                        MakeMaleReact(ped, playerPed, playerCoords)
                    end
                end)
            end,
            distance = 5.0
        }
    })
end)

-- Event to apply effect (from server/item)
RegisterNetEvent('mack-hardon:client:applyEffect', function()
    ActivateLocalEffect()
end)

-- Event to remove effect
RegisterNetEvent('mack-hardon:client:removeEffect', function()
    if effectActive then
        DeactivateLocalEffect()
        TriggerEvent('bln_notify:send', {
            title = _L('calmed_down'),
            icon = 'star',
            placement = 'middle-right',
            duration = 3000
        })
    else
        TriggerEvent('bln_notify:send', {
            title = _L('nothing_to_calm'),
            icon = 'star',
            placement = 'middle-right',
            duration = 3000
        })
    end
end)

-- TOGGLE AUTO HARDON COMMAND
RegisterCommand('toggleautohardon', function()
    Config.AutoHardonEnabled = not Config.AutoHardonEnabled
    
    local status = Config.AutoHardonEnabled and _L('auto_hardon_enabled') or _L('auto_hardon_disabled')
    
    TriggerEvent('bln_notify:send', {
        title = status,
        icon = 'star',
        placement = 'middle-right',
        duration = 3000
    })
end, false)



AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Clean up all synced props
        for playerId, prop in pairs(syncedProps) do
            if DoesEntityExist(prop) then
                DeleteEntity(prop)
            end
        end
        syncedProps = {}
        DeactivateLocalEffect()
        exports.ox_target:removeGlobalPed('hardon_show_off')
    end
end)
