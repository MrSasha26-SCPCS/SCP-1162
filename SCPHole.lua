local GameObject = CS.UnityEngine.GameObject
local Time = CS.UnityEngine.Time
local Vector3 = CS.UnityEngine.Vector3
local Player = CS.Player

local function FindInactiveRoom(name)
    local netRooms = CS.UnityEngine.Resources.FindObjectsOfTypeAll(typeof(CS.NetRoom))
    for i = 0, netRooms.Length - 1 do
        local netRoom = netRooms[i]
        if netRoom.roomObj.name == name then
            return netRoom.roomObj
        end
    end
    return nil
end

local function tableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

---@class SCPHole:CS.Akequ.Base.Room
SCPHole = {}

SCPHole.time = 0
SCPHole.created = false

function SCPHole:Init()
    print("Server init")
end

function SCPHole:Update()
    if self.main.netEvent.isServer then
        if self.time > 0 then
            self.time = self.time - Time.deltaTime
        end
    end 
    if self.main.netEvent.isClient then
        if not self.created then            
            self:CreateHole()
        end
    end
end

--SERVER

function SCPHole:SCPHolePressed(conn)
    local ply = CS.PlayerUtilities.GetServerPlayer(conn)
    if ply.playerClass ~= nil and ply.currentItem ~= nil and self.time <= 0 then
        self.time = 5
        local item = ply.currentItem
        if not ply.playerClass:GetType().Name:find("SCP") then
            local refine_item = item            
            ply:RemoveItemOnServer(item)
            local refine_items = nil
            if refine_item:GetType().Name == "Coin" then
                refine_items = { "FoundationAgentCard", "Flashlight", "SCP420J", "Candy", "AssistantCard", "SCP500", "Radio", "Cuffer" }
            elseif refine_item:GetType().Name == "Flashlight" then
                refine_items = { "FlashGrenade" }
            elseif refine_item:GetType().Name == "FlashGrenade" then
                refine_items = { "FragGrenade" }
            elseif refine_item:GetType().Name == "FragGrenade" then
                refine_items = { "FlashGrenade" }
            elseif refine_item:GetType().Name == "MicroHID" then
                refine_items = { "MicroHID" }
            elseif refine_item:GetType().Name == "CZ75B" or refine_item:GetType().Name == "USP" then
                refine_items = { "CZ75B", "USP" }
            elseif refine_item:GetType().Name == "AK12" or refine_item:GetType().Name == "ASVAL" or
            refine_item:GetType().Name == "FAL" or refine_item:GetType().Name == "G36C" or
            refine_item:GetType().Name == "G56" or refine_item:GetType().Name == "M170" or
            refine_item:GetType().Name == "SR3M" or refine_item:GetType().Name == "VSS" then
                refine_items = { "AK12", "ASVAL", "G56", "M170", "SR3M", "VSS" }
            elseif refine_item:GetType().Name == "JanitorCard" or refine_item:GetType().Name == "AssistantCard" or
            refine_item:GetType().Name == "FoundationAgentCard" or refine_item:GetType().Name == "RecruitCard" then
                refine_items = { "FoundationAgentCard", "JanitorCard", "AssistantCard", "RecruitCard" }
            elseif refine_item:GetType().Name == "ScientistCard" or refine_item:GetType().Name == "GuardCard" or
            refine_item:GetType().Name == "ZoneManagerCard" or refine_item:GetType().Name == "EngineerCard" then
                refine_items = { "ScientistCard", "GuardCard", "ZoneManagerCard", "EngineerCard" }
            elseif refine_item:GetType().Name == "SeniorScientistCard" or refine_item:GetType().Name == "MTFOperativeCard" or
            refine_item:GetType().Name == "FacilityManagerCard" or refine_item:GetType().Name == "ContainmentSpecialistCard" then
                refine_items = { "SeniorScientistCard", "MTFOperativeCard", "FacilityManagerCard", "ContainmentSpecialistCard" }
            elseif refine_item:GetType().Name == "AnalystCard" or refine_item:GetType().Name == "MTFCommanderCard" or
            refine_item:GetType().Name == "FacilityDirectorCard" or refine_item:GetType().Name == "SeniorEngineerCard" or
            refine_item:GetType().Name == "BreakingCard" then
                refine_items = { "AnalystCard", "MTFCommanderCard", "FacilityDirectorCard", "SeniorEngineerCard", "BreakingCard" }
            end
            if refine_items ~= nil then
                ply:GiveItem(refine_items[math.floor(CS.UnityEngine.Random.Range(1, tableLength(refine_items)+1))])
            end
        end
    end
end

--CLIENT

function SCPHole:CreateHole()
    self.created = true
    
    local room = FindInactiveRoom("Map_LC_173(Clone)")
    if room ~= nil then

        local bundle = CS.ScriptHelper.LoadBundle("scp1162")
        local mat = bundle:LoadAsset("scp1162.mat")
        local texture = bundle:LoadAsset("scp1162mat.png")
        local shader = bundle:LoadAsset("shader.shader")
        local plane = GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Plane)
        if plane ~= nil then                
            plane.transform:SetParent(room.transform)
            plane.transform.localScale = Vector3(0.1, 0.1, 0.1)
            plane.transform.localPosition = Vector3(4.327, 11.5, -4.93)
            plane.transform.localRotation = CS.UnityEngine.Quaternion.Euler(90, 0, 0)
            local button = plane:AddComponent(typeof(CS.Button))
            plane.layer = 6
            local interactionCollider = plane:AddComponent(typeof(CS.UnityEngine.BoxCollider))
            interactionCollider.isTrigger = true
            interactionCollider.size = Vector3.one
            button.call = function() self.main:SendToServer("SCPHolePressed") end
            plane:GetComponent(typeof(CS.UnityEngine.MeshRenderer)).material = mat
            plane:GetComponent(typeof(CS.UnityEngine.MeshRenderer)).material.mainTexture = texture
            plane:GetComponent(typeof(CS.UnityEngine.MeshRenderer)).material.shader = shader
        end
    end
end

return SCPHole