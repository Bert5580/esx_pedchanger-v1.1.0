local ESX = nil

-- ESX Legacy export pattern (supports both getSharedObject styles)
CreateThread(function()
  while ESX == nil do
    if exports and exports['es_extended'] and exports['es_extended'].getSharedObject then
      ESX = exports['es_extended']:getSharedObject()
    end
    if ESX == nil and TriggerEvent then
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
    Wait(250)
  end
end)

local function logInfo(...)
  if Config.PrintInfo then
    print(("[esx_pedchanger] %s"):format(table.concat({...}, " ")))
  end
end

local function logDebug(...)
  if Config.PrintDebug then
    print(("[esx_pedchanger:DEBUG] %s"):format(table.concat({...}, " ")))
  end
end

-- Ensure table exists on start
AddEventHandler('onMySQLReady', function()
  MySQL.Async.execute([[
    CREATE TABLE IF NOT EXISTS `player_peds` (
      `identifier` VARCHAR(60) NOT NULL,
      `ped_model` VARCHAR(64) NOT NULL,
      `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`identifier`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]], {}, function(_)
    logInfo("Table `player_peds` verified/created.")
  end)
end)

local function hasPermission(xPlayer)
  if not xPlayer then return false end
  if Config.RequireESXGroup and Config.RequireESXGroup ~= '' then
    if (xPlayer.getGroup and xPlayer.getGroup() == Config.RequireESXGroup) then
      return true
    end
  else
    return true
  end
  return false
end

local function isAllowedAce(src)
  if not Config.RequireAce or Config.RequireAce == '' then return true end
  local allowed = IsPlayerAceAllowed(src, Config.RequireAce)
  return allowed == true
end

local function sanitizeModelName(model)
  if not model or model == '' then return nil end
  model = string.lower(model)
  return model
end

local function savePlayerPed(identifier, model)
  if not identifier or not model then return end
  MySQL.Async.execute('REPLACE INTO player_peds (identifier, ped_model) VALUES (?, ?)',
    {identifier, model},
    function(rowsChanged)
      logDebug("Saved ped for", identifier, "->", model, "rows:", tostring(rowsChanged))
    end
  )
end

local function getSavedPed(identifier, cb)
  if not identifier then cb(nil); return end
  MySQL.Async.fetchScalar('SELECT ped_model FROM player_peds WHERE identifier = ?', {identifier},
    function(model)
      cb(model)
    end
  )
end

RegisterNetEvent('esx_pedchanger:savePed', function(model)
  local src = source
  local xPlayer = ESX and ESX.GetPlayerFromId and ESX.GetPlayerFromId(src)
  if not xPlayer then return end

  if not hasPermission(xPlayer) or not isAllowedAce(src) then
    TriggerClientEvent('chat:addMessage', src, { args = { '^1SYSTEM', 'You are not allowed to use this command.' } })
    return
  end

  local identifier = xPlayer.getIdentifier and xPlayer.getIdentifier() or xPlayer.identifier
  model = sanitizeModelName(model)
  if not identifier or not model or model == '' then return end

  savePlayerPed(identifier, model)
end)

-- Re-apply saved model when player spawns (first spawn after load)
RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
  local src = source
  if type(playerId) == 'number' then src = playerId end
  local xP = xPlayer or (ESX and ESX.GetPlayerFromId and ESX.GetPlayerFromId(src))
  if not xP then return end

  if not Config.Persist then return end

  local identifier = xP.getIdentifier and xP.getIdentifier() or xP.identifier
  if not identifier then return end

  getSavedPed(identifier, function(model)
    if model and model ~= '' then
      TriggerClientEvent('esx_pedchanger:applySavedPed', src, model)
      logInfo("Applied saved ped for", identifier, "->", model)
    end
  end)
end)
