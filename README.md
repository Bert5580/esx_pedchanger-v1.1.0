# esx_pedchanger (Optimized)

A lightweight **ESX Legacy** resource to change a player's model via a command and **persist** it using **mysql-async**.

## Features
- `/ped <model>` changes your player model immediately.
- Persists the chosen model to `player_peds` and auto-applies it on next login.
- Safe swap: brief invincibility to avoid ragdoll/fall damage (configurable).
- ESX permissions and ACE support (optional).
- Robust model loading with timeout and nil checks.
- Clean logging + zero-configuration SQL bootstrapping (auto-creates table).
- Lua 5.4 compatible; ESX Legacy shared object detection.

## Installation
1. Drop the **esx_pedchanger** folder in your `resources`.
2. Ensure `mysql-async` and `es_extended` are started before this resource.
3. (Optional) Import `sql/esx_pedchanger.sql` if you prefer manual migration.
4. In `server.cfg`:
   ```cfg
   ensure mysql-async
   ensure es_extended
   ensure esx_pedchanger
   ```

## Configuration (`config.lua`)
- `Config.Command` – Command name (`ped` by default).
- `Config.Persist` – Store and re-apply the model on next login.
- `Config.BriefInvincibilityMs` – Safety window during swaps.
- `Config.ModelLoadTimeout` – Max time to wait for model loading.
- `Config.RequireESXGroup` – Limit to an ESX group (e.g., `admin`). Leave empty to allow everyone.
- `Config.RequireAce` – Limit via ACE (e.g., `add_ace group.admin pedchanger.use allow`). Leave empty to allow everyone.
- `Config.Whitelist` / `Config.Blacklist` – Optional model allow/deny lists.
- `Config.PrintInfo` / `Config.PrintDebug` – Server-side logging.

## Commands
- `/ped <model>` – Set ped model and (if enabled) save it.
  - Example: `/ped a_m_m_business_01`

## Database
Table (auto-created on start if missing):
```sql
CREATE TABLE IF NOT EXISTS `player_peds` (
  `identifier` VARCHAR(60) NOT NULL,
  `ped_model` VARCHAR(64) NOT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## Troubleshooting
- **"Model not found"**: Ensure the spelling is correct and lowercased (e.g., `a_m_m_business_01`).
- **Permission denied**: Remove/adjust `Config.RequireESXGroup` and `Config.RequireAce`.
- **Nothing happens**: Check F8/Server console for errors; confirm `mysql-async` is connected and `es_extended` is loaded first.

## License
MIT (see `LICENSE.md` if present).
