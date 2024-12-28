local Zones = {}
local Active = {}
local Combo = nil

local function UpdateComboZone(zone)
  if Combo == nil then
    Combo = ComboZone:Create({zone}, {name="combo", debugPoly=false})
    Active[zone["name"]] = zone
    
    Combo:onPlayerInOutExhaustive(function(isPointInside, point, insideZones, enteredZones, leftZones)
      if enteredZones then
        for i=1, #enteredZones do
          TriggerEvent("ps-zones:enter", enteredZones[i]["name"], enteredZones[i]["data"])
          TriggerServerEvent("ps-zones:enter", enteredZones[i]["name"], enteredZones[i]["data"])
        end
      end
  
      if leftZones then
        for i=1, #leftZones do
          TriggerEvent("ps-zones:leave", leftZones[i]["name"], leftZones[i]["data"])
          TriggerServerEvent("ps-zones:leave", leftZones[i]["name"], leftZones[i]["data"])
        end
      end
    end)
  else
    Combo:AddZone(zone)
    Active[zone["name"]] = zone
  end
end

local function ZoneExist(name)
  return Active[name] ~= nil
end

local function CreateZone(type, name, ...)
  if ZoneExist(name) then
    print("Zone with that name already exists")
    return
  end
  local data = select(#{...}, ...) > 0 and select(#{...}, ...) or {}
  data.name = name

  local zone
  if type == "box" then
    zone = BoxZone:Create(...)
  elseif type == "poly" then
    zone = PolyZone:Create(...)
  elseif type == "circle" then
    zone = CircleZone:Create(...)
  elseif type == "entity" then
    zone = EntityZone:Create(...)
  else
    print("Unknown zone type")
    return
  end

  UpdateComboZone(zone)
end

exports("CreateBoxZone", function(name, point, length, width, data)
  CreateZone("box", name, point, length, width, data)
end)

exports("CreatePolyZone", function(name, points, data)
  CreateZone("poly", name, points, data)
end)

exports("CreateCircleZone", function(name, point, radius, data)
  CreateZone("circle", name, point, radius, data)
end)

exports("CreateEntityZone", function(name, entity, data)
  CreateZone("entity", name, entity, data)
end)

exports("DestroyZone", function(name)
  if not ZoneExist(name) then
    print("Zone doesn't exist")
    return
  end
  Combo:RemoveZone(Active[name])
  Active[name]:destroy()
  Active[name] = nil
end)
