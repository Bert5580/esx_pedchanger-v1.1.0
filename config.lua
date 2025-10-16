Config = {}

-- Optional: restrict the command to this ACE principal or ESX group (leave empty to allow everyone)
Config.RequireAce = ''          -- example: 'pedchanger.use'
Config.RequireESXGroup = ''     -- example: 'admin' (uses xPlayer.getGroup())

-- Command name
Config.Command = 'ped'

-- Whether to apply a brief invincibility when swapping models to avoid ragdolling/fall damage
Config.BriefInvincibilityMs = 1200

-- Whether to persist the last chosen ped model in the database
Config.Persist = true

-- Maximum time (ms) to wait for model loading
Config.ModelLoadTimeout = 5000

-- Optional whitelist (empty = allow any model hash the game knows). Model names must be lowercase strings.
Config.Whitelist = {
  -- 'a_m_m_business_01',
  -- 'a_m_m_eastsa_01'
}

-- Optional blacklist (checked if Whitelist is empty). Lowercase names.
Config.Blacklist = {
  'player_zero', 'player_one', 'player_two'  -- avoid story protagonists if you wish
}

-- Logging
Config.PrintInfo = true   -- print informational messages server-side
Config.PrintDebug = false -- more verbose debug
