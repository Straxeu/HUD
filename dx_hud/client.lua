local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 126, ["N6"] = 107, ["N+"] = 314, ["N-"] = 97, ["N7"] = 117, ["N8"] = 127, ["N9"] = 118, ["ARROWDOWN"] = 187, ["ARROWUP"] = 188
}

ESX = nil
ESX = exports["es_extended"]:getSharedObject()

hudhidden = false
cooldown = 0
local cooldown = 0
local state = 1
local PlayerData                = {}
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
            PlayerData = ESX.GetPlayerData()
        end)
        Citizen.Wait(0)
        ESX.UI.HUD.HideHud()
        Citizen.Wait(3000)
        while not ESX.IsPlayerLoaded() do Wait(100); end
        if PlayerData.job.name == "police" or PlayerData.job.name == "sahp" or PlayerData.job.name == "ranger" or PlayerData.job.name == "sheriff" then
            obtainrole()
            state = 1
        else
            hiderole()
            state = 2
        end

        ESX.TriggerServerCallback('rng_ui:getId', function(myid)
            TriggerEvent("ESX_FWD_UI:myid_data", myid)
        end, PlayerData.job)
    end
end)

Citizen.CreateThread( function()
  while true do Wait(0) 
    SetPedConfigFlag(PlayerPedId(), 35, false)
  end
end)


local playersetup = false


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    SetupCharacter()
end)

function SetupCharacter()
    Citizen.Wait(0)
    PlayerData = ESX.GetPlayerData()
    if PlayerData.job.name == "police" or PlayerData.job.name == "sahp" or PlayerData.job.name == "ranger" or PlayerData.job.name == "sheriff" then
        obtainrole()
        state = 1
    else
        hiderole()
        state = 2
    end

    ESX.TriggerServerCallback('rng_ui:getId', function(myid)
        TriggerEvent("ESX_FWD_UI:myid_data", myid)
    end, PlayerData.job)
    ESX.UI.HUD.UpdateElement('job', {
        job_label = PlayerData.job.label,
        grade_label = PlayerData.job.grade_label
    })
end

local vehiclesCars = {0,1,2,3,4,5,6,7,8,9,10,11,12,17,18,19,20};

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rng_ui:getMyId', function(myid)
        TriggerEvent("ESX_FWD_UI:myid_data", myid)
    end)
end)

RegisterNetEvent('rng_ui:show_id')
AddEventHandler('rng_ui:show_id', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('rng_ui:show_id', GetPlayerServerId(closestPlayer))
    else
        ESX.ShowNotification('~r~Zadna ~w~osoba neni v okoli')
    end
end)

local stuntime = 15000

Citizen.CreateThread(function()
    while ESX == nil do Wait(100); end
    while not ESX.IsPlayerLoaded() do Wait(100); end
    SetupCharacter()
    while true do
        Citizen.Wait(0)
        if IsPedBeingStunned(GetPlayerPed(-1)) then
            SetPedMinGroundTimeForStungun(GetPlayerPed(-1), stuntime)
        end
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if DoesEntityExist(veh) and not IsEntityDead(veh) then
            local model = GetEntityModel(veh)
            -- If it's not a boat, plane or helicopter, and the vehilce is off the ground with ALL wheels, then block steering/leaning left/right/up/down.
            if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) and IsEntityInAir(veh) then
                DisableControlAction(0, 59) -- leaning left/right
                DisableControlAction(0, 60) -- leaning up/down
            end
        end
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    while not ESX.IsPlayerLoaded() do Wait(100); end
  PlayerData = xPlayer
  Citizen.Wait(5000)
  if PlayerData.job.name == "police" or PlayerData.job.name == "sheriff" or PlayerData.job.name == "ranger" or PlayerData.job.name == "sahp" then
    obtainrole()
    state = 1
  else
    hiderole()
    state = 2
  end
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
  if PlayerData.job.name == "police" or PlayerData.job.name == "sheriff" or PlayerData.job.name == "ranger" or PlayerData.job.name == "sahp" then
    obtainrole()
    state = 1
  else
    hiderole()
    state = 2
  end
end)

function obtainrole()
    ESX.TriggerServerCallback('rng_ui:getCopName', function(myname)
        SendNUIMessage({
            action = "updatename",
            name = myname,
        })
        SendNUIMessage({
            action = "showdashcam",
        })
    end)
end

function hiderole()
    SendNUIMessage({
        action = "hidedashcam",
    })
end


RegisterCommand('camon', function(source, args)
    if PlayerData.job == nil then
        PlayerData.job = ESX.GetPlayerData().job
    end
    if PlayerData.job.name == "police" or PlayerData.job.name == "sheriff" or PlayerData.job.name == "ranger" or PlayerData.job.name == "sahp" then
        if state == 2 then
            state = 1
            SendNUIMessage({
                action = "showdashcam",
            })
        end
    end
end)

RegisterCommand('camoff', function(source, args)
    if PlayerData.job == nil then
        PlayerData.job = ESX.GetPlayerData().job
    end
    if PlayerData.job.name == "police" or PlayerData.job.name == "sheriff" or PlayerData.job.name == "ranger" or PlayerData.job.name == "sahp" then
        if state == 1 then
            state = 2
            SendNUIMessage({
                action = "hidedashcam",
            })
        end
    end
end)

local player = GetPlayerPed(-1)

local directions = { [0] = 'S', [1] = 'SZ', [2] = 'Z', [3] = 'JZ', [4] = 'J', [5] = 'JV', [6] = 'V', [7] = 'SV', [8] = 'S' } 
local zones = { ['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz" }

interactionDistance = 3.5
lockDistance = 25
engineoff = false
saved = false
controlsave_bool = false
IsEngineOn = true
local raw = LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'postal_file'))
local postals = json.decode(raw)
local nearest = nil
local pBlip = nil
local disableShuffle = true
inVehicle = false
local vehicleCruiser = 'off'

Citizen.CreateThread(function()
    while ESX == nil do Wait(100); end
    while not ESX.IsPlayerLoaded() do Wait(100); end
    SendNUIMessage({
        action = "hudStatus",
        state = 0
    })
    while true do
        Citizen.Wait(500)     
        local player = GetPlayerPed(-1)

        if inVehicle then
            if hudhidden == false then
                DisplayRadar(true)
            else
                DisplayRadar(false)
            end
            PedCar = GetVehiclePedIsIn(PlayerPedId(), false)
            if IsVehicleEngineOn(PedCar) then
                local vehicleSpeedSource = GetEntitySpeed(PedCar)
                local vehicleSpeed
                vehicleSpeed = math.ceil(vehicleSpeedSource * 2.237)

                local vehicleVal,vehicleLights,vehicleHighlights  = GetVehicleLightsState(PedCar)
                local vehicleIsLightsOn
                if vehicleLights == 1 and vehicleHighlights == 0 then
                    vehicleIsLightsOn = 'normal'
                elseif (vehicleLights == 1 and vehicleHighlights == 1) or (vehicleLights == 0 and vehicleHighlights == 1) then
                    vehicleIsLightsOn = 'on'
                else
                    vehicleIsLightsOn = 'off'
                end

                local vehicleGear = GetVehicleCurrentGear(PedCar)

                if (vehicleSpeed == 0 and vehicleGear == 0) or (vehicleSpeed == 0 and vehicleGear == 1) then
                    vehicleGear = 'N'
                elseif vehicleSpeed > 0 and vehicleGear == 0 then
                    vehicleGear = 'R'
                end

                percentage = math.ceil((vehicleSpeed / 200) * 100)
                if percentage > 100 then
                    percentage = 100
                end

                SendNUIMessage({
                    action = "carData",
                    vehicleengine = 1,
                    invehicle = 1,
                    carspeed = vehicleSpeed,
                    percent = percentage,
                    cruiser = vehicleCruiser,
                    gear = vehicleGear,
                    speed = math.ceil(GetEntitySpeed(PedCar)),
                    fuel = math.ceil(GetVehicleFuelLevel(PedCar)),
                })
            else
                local vehicleGear = GetVehicleCurrentGear(PedCar)
                SendNUIMessage({
                    action = "carData",
                    invehicle = 1,
                    cruiser = vehicleCruiser,
                    percent = 0,
                    fuel = math.ceil(GetVehicleFuelLevel(PedCar)),
                    carspeed = 0,
                    vehicleengine = 0,
                })
            end
        else
            DisplayRadar(false)
        end

        if IsPedInAnyVehicle(player, true) then
            if inVehicle == false then
                SendNUIMessage({
                    action = "hudStatus",
                    state = 1
                })
            end
            inVehicle = true
        else
            if inVehicle == true then
                SendNUIMessage({
                    action = "hudStatus",
                    state = 0
                })
            end
            inVehicle = false
        end

        if nearest then
            TriggerEvent("ESX_FWD_UI:postal_data", postals[nearest.i].code, nearest.d)
        end
        local heading = directions[math.floor((GetEntityHeading(player) + 22.5) / 45.0)]
        local position = GetEntityCoords(player)
        local zoneNameFull = zones[GetNameOfZone(position.x, position.y, position.z)]
        local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(position.x, position.y, position.z))
        local locationText = heading
        locationText = (streetName == "" or streetName == nil) and (locationText) or (locationText .. " | " .. streetName)
        locationText = (zoneNameFull == "" or zoneNameFull == nil) and (locationText) or (locationText .. " | " .. zoneNameFull)
        local playerName = GetPlayerName(PlayerId())
        freq = 0
        SendNUIMessage({
            action = "updateStreet",
            frequency = freq,
            st = locationText,
        })
    end
end)


local vestatus = 0
local vehicleSignalIndicator = 'off'
local seatbeltEjectSpeed = 45.0 
local seatbeltEjectAccel = 100.0
local seatbeltIsOn = false
local currSpeed = 0.0
local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
Citizen.CreateThread(function()
    while ESX == nil do Wait(100); end
    while not ESX.IsPlayerLoaded() do Wait(100); end
    while true do
        Wait(500)
        playerped = PlayerPedId()
        local isweapon, weaponHash = GetCurrentPedWeapon(playerped, true)
        local isammo, ammo = GetAmmoInClip(playerped, weaponHash)
        local max_clip_ammo = GetMaxAmmoInClip(playerped, weaponHash, true)
        local maxAmmo = GetAmmoInPedWeapon(playerped, weaponHash)
        local ammoText = ammo.."/"..(maxAmmo - (ammo))
        SendNUIMessage({
            action = "updateWeapon",
            nuiammo = ammoText
        })
    end
end)

Citizen.CreateThread(function()
    while ESX == nil do Wait(100); end
    while not ESX.IsPlayerLoaded() do Wait(100); end
    while true do
        local x, y = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        local ndm = -1
        local ni = -1
        for i, p in ipairs(postals) do
            local dm = (x - p.x) ^ 2 + (y - p.y) ^ 2
            if ndm == -1 or dm < ndm then
                ni = i
                ndm = dm
            end
        end
        if ni ~= -1 then
            local nd = math.sqrt(ndm)
            nearest = {i = ni, d = nd}
        end
        if pBlip then
            local b = {x = pBlip.p.x, y = pBlip.p.y}
            local dm = (b.x - x) ^ 2 + (b.y - y) ^ 2
            if dm < config.blip.distToDelete ^ 2 then
                RemoveBlip(pBlip.hndl)
                pBlip = nil
            end
        end
        Wait(1000)
    end
end)


Citizen.CreateThread(function()
    while ESX == nil do Wait(100); end
    while not ESX.IsPlayerLoaded() do Wait(100); end
    local dict = "amb@world_human_hang_out_street@female_arms_crossed@base"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(1)
    end
    local handsup = false

    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(1)
    SetRadarBigmapEnabled(false, false)
    while true do
        Citizen.Wait(0)

        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        local myPed = GetPlayerPed(-1)

        if IsControlJustPressed(1, 243) then
            if not handsup then
                TaskPlayAnim(GetPlayerPed(-1), dict, "base", 8.0, 8.0, -1, 50, 0, false, false, false)
                handsup = true
            else
                handsup = false
                ClearPedTasks(GetPlayerPed(-1))
            end
        end

        if IsPedInAnyVehicle(GetPlayerPed(-1), false) and disableShuffle then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) == GetPlayerPed(-1) then
                if GetIsTaskActive(GetPlayerPed(-1), 165) then
                    SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                end
            end
        end

        if not IsControlPressed(1, Keys['LEFTSHIFT']) and IsControlJustReleased(0, Keys['Y']) and IsInputDisabled(0) then
            TriggerEvent('pv:setCruiseSpeed')
        end

        if IsControlPressed(1, Keys['LEFTSHIFT']) and IsControlJustReleased(0, Keys['Y']) and IsInputDisabled(0) then
            local player = GetPlayerPed(-1)
            local vehicle = GetVehiclePedIsIn(player, false)
            local vehicleSpeedSource = GetEntitySpeed(vehicle)

            if vehicleCruiser == 'on' then
                vehicleCruiser = 'off'
                SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel"))
                
            else
                vehicleCruiser = 'on'
                SetEntityMaxSpeed(vehicle, vehicleSpeedSource)
            end
        end
        if IsControlJustPressed(1, Keys["N+"]) then
            TriggerEvent("SeatShuffle")
        end

        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)


RegisterNetEvent("SeatShuffle")
AddEventHandler("SeatShuffle", function()
    if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        disableSeatShuffle(false)
        Citizen.Wait(5000)
        disableSeatShuffle(true)
    else
        CancelEvent()
    end
end)

RegisterCommand("shuff", function(source, args, raw)
    TriggerEvent("SeatShuffle")
end, false)

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    while ESX == nil do Wait(100); end
    while not ESX.IsPlayerLoaded() do Wait(100); end
    while true do
        Citizen.Wait(1000)
        local playerped = GetPlayerPed(-1)
        SetPedMaxTimeUnderwater(playerped, 30.0)
        staminaremaining = 100 - math.floor(GetPlayerSprintStaminaRemaining(PlayerId()))
        if IsPedSwimmingUnderWater(playerped) then
            podvodou = 1
            lefttime = GetPlayerUnderwaterTimeRemaining(PlayerId())
            SendNUIMessage({
                action = "updateHealth",
                value = GetEntityHealth(playerped) - 100,
                valuearmor = GetPedArmour(playerped),
                valuestamina = staminaremaining,
                podvodou = podvodou,
                lefttime = lefttime
            })
        else
            podvodou = 0
            lefttime = 0
            SendNUIMessage({
                action = "updateHealth",
                value = GetEntityHealth(playerped) - 100,
                valuearmor = GetPedArmour(playerped),
                valuestamina = staminaremaining,
                podvodou = podvodou,
                lefttime = lefttime
            })
        end

    end
end)

RegisterCommand(
    'postal',
    function(source, args, raw)
        if #args < 1 then
            if pBlip then
                RemoveBlip(pBlip.hndl)
                pBlip = nil
                TriggerEvent(
                    'chat:addMessage',
                    {
                        color = {255, 0, 0},
                        args = {
                            'BOD',
                            config.blip.deleteText
                        }
                    }
                )
            end
            return
        end
        local n = string.upper(args[1])

        local fp = nil
        for _, p in ipairs(postals) do
            if string.upper(p.code) == n then
                fp = p
            end
        end

        if fp then
            if pBlip then
                RemoveBlip(pBlip.hndl)
            end
            pBlip = {hndl = AddBlipForCoord(fp.x, fp.y, 0.0), p = fp}
            SetBlipRoute(pBlip.hndl, true)
            SetBlipSprite(pBlip.hndl, config.blip.sprite)
            SetBlipColour(pBlip.hndl, config.blip.color)
            SetBlipRouteColour(pBlip.hndl, config.blip.color)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(config.blip.blipText:format(pBlip.p.code))
            EndTextCommandSetBlipName(pBlip.hndl)

            TriggerEvent(
                'chat:addMessage',
                {
                    color = {255, 0, 0},
                    args = {
                        'BOD',
                        config.blip.drawRouteText:format(fp.code)
                    }
                }
            )
        else
            TriggerEvent(
                'chat:addMessage',
                {
                    color = {255, 0, 0},
                    args = {
                        'BOD',
                        config.blip.notExistText
                    }
                }
            )
        end
    end
)

RegisterNetEvent("rng_ui:send_needs")
AddEventHandler("rng_ui:send_needs", function(needsdata)
	SendNUIMessage({
		action = "updateHunger",
		value = (100 * (needsdata[1].val / 1000000)),
	})		
	SendNUIMessage({
		action = "updateThirst",
		value = (100 * (needsdata[2].val / 1000000)),
	})			
end)

RegisterNetEvent('ESX_FWD_UI:myid_data')
AddEventHandler('ESX_FWD_UI:myid_data', function(myid)
    SendNUIMessage({
        action = "update_myid",
        userid = myid,
    })
end)

RegisterNetEvent('ESX_FWD_UI:front_data')
AddEventHandler('ESX_FWD_UI:front_data', function(data)
    SendNUIMessage({
        action = "front_set",
        datax = data
    })
end)
RegisterNetEvent('ESX_FWD_UI:back_data')
AddEventHandler('ESX_FWD_UI:back_data', function(data)
    SendNUIMessage({
        action = "back_set",
        datax = data
    })
end)

RegisterNetEvent('ESX_FWD_UI:postal_data')
AddEventHandler('ESX_FWD_UI:postal_data', function(dataa, datab)
    SendNUIMessage({
        action = "update_postal",
        nearest = dataa,
        longdata = datab,
    })
end)

RegisterNetEvent('ESX_FWD_UI:show_speedometer')
AddEventHandler('ESX_FWD_UI:show_speedometer', function()
    SendNUIMessage({
        action = "show_speedometer",
    })
end)


RegisterNetEvent('ESX_FWD_UI:hide_speedometer')
AddEventHandler('ESX_FWD_UI:hide_speedometer', function()
    SendNUIMessage({
        action = "hide_speedometer",
    })
end)


RegisterNetEvent('ESX_FWD_UI:hidehud')
AddEventHandler('ESX_FWD_UI:hidehud', function()
    hudhidden = true
    SendNUIMessage({
        action = "hideHud",
    })
end)

RegisterNetEvent('ESX_FWD_UI:set_time')
AddEventHandler('ESX_FWD_UI:set_time', function(time)
    SendNUIMessage({
        action = "settime",
        datax = time
    })
end)



RegisterNetEvent('ESX_FWD_UI:showhud')
AddEventHandler('ESX_FWD_UI:showhud', function()
    hudhidden = false
    SendNUIMessage({
        action = "showHud",
    })
end)



function ShowNotification( text )
    SetNotificationTextEntry( "STRING" )
    AddTextComponentString( text )
    DrawNotification( false, false )
end
function disableSeatShuffle(flag)
    disableShuffle = flag
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function NotificationMessage(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(0,1)
end
