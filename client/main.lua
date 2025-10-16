local function notify(msg)
  BeginTextCommandThefeedPost("STRING")
  AddTextComponentSubstringPlayerName(msg or "")
  EndTextCommandThefeedPostTicker(false, true)
end

local function modelExists(name)
  if not name or name == "" then return false end
  local hash = GetHashKey(name)
  if not IsModelValid(hash) then return false end
  return true
end

local function loadModelBlocking(modelName, timeoutMs)
  local hash = type(modelName) == "number" and modelName or GetHashKey(modelName)
  if not IsModelValid(hash) then return false, "Invalid model" end

  local deadline = GetGameTimer() + (timeoutMs or 5000)
  RequestModel(hash)
  while not HasModelLoaded(hash) do
    if GetGameTimer() > deadline then
      return false, "Timed out loading model"
    end
    Wait(0)
    RequestModel(hash)
  end
  return true, hash
end

local function briefInvincible(ms)
  local ped = PlayerPedId()
  SetEntityInvincible(ped, true)
  SetPedCanRagdoll(ped, false)
  SetPlayerInvincible(PlayerId(), true)
  Wait(ms or 1000)
  SetPlayerInvincible(PlayerId(), false)
  SetPedCanRagdoll(ped, true)
  SetEntityInvincible(ped, false)
end

local function applyBasicOutfit(ped)
  -- Reset some components to avoid mismatched clothing after model swap
  ClearAllPedProps(ped)
  for comp = 0, 11 do
    local draw = GetNumberOfPedDrawableVariations(ped, comp)
    if draw > 0 then
      SetPedComponentVariation(ped, comp, 0, 0, 0)
    end
  end
end

RegisterNetEvent('esx_pedchanger:applySavedPed', function(model)
  if not model or model == "" then return end
  if not modelExists(model) then
    notify(("~r~Saved ped '%s' no longer exists."):format(model))
    return
  end

  local ok, res = loadModelBlocking(model, Config.ModelLoadTimeout)
  if not ok then
    notify(("~r~Failed to load model: %s"):format(res))
    return
  end
  local hash = res
  local ped = PlayerPedId()

  if Config.BriefInvincibilityMs and Config.BriefInvincibilityMs > 0 then
    briefInvincible(Config.BriefInvincibilityMs)
  end

  SetPlayerModel(PlayerId(), hash)
  SetPedDefaultComponentVariation(PlayerPedId())
  SetModelAsNoLongerNeeded(hash)
  applyBasicOutfit(PlayerPedId())

  notify(("~g~Applied saved ped: ~w~%s"):format(model))
end)

RegisterCommand(Config.Command, function(_, args)
  local model = (args[1] or ""):lower()

  if model == "" then
    notify(("~y~Usage: ~w~/%%s <ped_model>  e.g., /%s a_m_m_business_01"):format(Config.Command))
    return
  end

  if not modelExists(model) then
    notify(("~r~Model not found: ~w~%s"):format(model))
    return
  end

  local ok, res = loadModelBlocking(model, Config.ModelLoadTimeout)
  if not ok then
    notify(("~r~Failed to load model: %s"):format(res))
    return
  end
  local hash = res

  if Config.BriefInvincibilityMs and Config.BriefInvincibilityMs > 0 then
    briefInvincible(Config.BriefInvincibilityMs)
  end

  SetPlayerModel(PlayerId(), hash)
  SetPedDefaultComponentVariation(PlayerPedId())
  SetModelAsNoLongerNeeded(hash)
  applyBasicOutfit(PlayerPedId())

  -- persist (server)
  if Config.Persist then
    TriggerServerEvent('esx_pedchanger:savePed', model)
  end

  notify(("~g~Ped set to: ~w~%s"):format(model))
end, false)

-- Helpful suggestion text
TriggerEvent('chat:addSuggestion', ("/" .. Config.Command), "Change your player model and save it", {
  { name = "ped_model", help = "e.g., a_m_m_business_01" }
})
