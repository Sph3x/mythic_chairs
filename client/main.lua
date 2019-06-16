local sitting = false
local pos = nil
local lastPos = nil
local currentSitObj = nil
local currentScenario = nil
local data = nil
local object = nil
local distance = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = GetPlayerPed(-1)

		if sitting and not IsPedUsingScenario(playerPed, currentScenario) then
			Standup()
		end
	end
end)

RegisterNetEvent('mythic_chairs:client:StartSit')
TriggerEvent('mythic_chairs:client:StartSit', function()
    if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
        if sitting then
            Standup()
        else
            local chair = exports['mythic_base']:getClosestObject(Config.Props)
            object = chair.object
            distance = chair.distance

            if distance < 1.5 then

                local hash = GetEntityModel(object)
                data = nil
                local modelName = nil
                local found = false

                for k,v in pairs(Config.Sitable) do
                    if GetHashKey(k) == hash then
                        data = v
                        modelName = k
                        found = true
                        break
                    end
                end

                if found == true then
                    sit(object, modelName, data)
                end
            else
                exports['mythic_notify']:DoHudText('error', 'Not Near Something To Sit On')
            end
        end
    else
        exports['mythic_notify']:DoHudText('error', 'Can\'t Do That In A Vehicle')
    end
end)

function Standup()
    local playerPed = GetPlayerPed(-1)
	ClearPedTasks(playerPed)
	sitting = false
	SetEntityCoords(playerPed, lastPos)
	FreezeEntityPosition(playerPed, false)
	FreezeEntityPosition(currentSitObj, false)
	TriggerServerEvent('mythic_chairs:server:LeaveChair', currentSitObj)
	currentSitObj = nil
	currentScenario = nil
end

function sit(object, modelName, data)
	pos = GetEntityCoords(object)
	local id = pos.x .. pos.y .. pos.z
    TriggerServerEvent('mythic_chairs:server:GetChair', id)
end

RegisterNetEvent('mythic_chairs:client:GetChair')
AddEventHandler('mythic_chairs:client:GetChair', function(occupied)
    if occupied then
        exports['mythic_notify']:DoHudText('error', 'Chair Is Occupied')
    else
        local playerPed = GetPlayerPed(-1)
        lastPos = GetEntityCoords(playerPed)
        currentSitObj = id
        TriggerServerEvent('mythic_chairs:server:TakeChair', id)
        FreezeEntityPosition(object, true)
        currentScenario = data.scenario
        TaskStartScenarioAtPosition(playerPed, currentScenario, pos.x, pos.y, pos.z - data.verticalOffset, GetEntityHeading(object) + 180.0, 0, true, true)
        sitting = true
    end
end)