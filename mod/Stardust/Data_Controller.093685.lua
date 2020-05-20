--- This disk represents all of the 'data' in the game (e.g. giant JSON).
--
-- In future versions of the prototype, this will be downloaded asynchronously
-- and cached in onSave instead of requiring everything to be inlined here.
--
-- @module Data_Controller

_UNITS = {
  GalacticEmpire = {
    Corps = {
      {
        name = 'Stormtroopers',
        base = 'Small',
        rank = 'Corps',
        card = 'https://assets.swlegion.dev/units/empire/stormtroopers.card.png',
        models = {
          {
            mesh = 'https://assets.swlegion.dev/units/empire/stormtroopers.1.obj',
            texture = 'https://assets.swlegion.dev/units/empire/stormtroopers.diffuse.jpg'
          },

          {
            mesh = 'https://assets.swlegion.dev/units/empire/stormtroopers.2.obj'
          },

          {
            mesh = 'https://assets.swlegion.dev/units/empire/stormtroopers.3.obj'
          },

          {
            mesh = 'https://assets.swlegion.dev/units/empire/stormtroopers.4.obj'
          }
          }
        }
      }
    },

    RebelAlliance = {
      Corps = {
        {
          name = 'Rebel Troopers',
          base = 'Small',
          rank = 'Corps',
          card = 'https://assets.swlegion.dev/units/rebels/rebel_troopers.card.png',
          models = {
            {
              mesh = 'https://assets.swlegion.dev/units/rebels/rebel_troopers.1.obj',
              texture = 'https://assets.swlegion.dev/units/rebels/rebel_troopers.diffuse.jpg'
            },

            {
              mesh = 'https://assets.swlegion.dev/units/rebels/rebel_troopers.2.obj'
            },

            {
              mesh = 'https://assets.swlegion.dev/units/rebels/rebel_troopers.3.obj'
            },

            {
              mesh = 'https://assets.swlegion.dev/units/rebels/rebel_troopers.4.obj'
            }
          }
        }
      }
    },
}

_UPGRADES = {
  GalacticEmpire = {
    HeavyWeapon = {
      {
        name = 'DLT-19 Stormtrooper',
        card = 'https://assets.swlegion.dev/upgrades/empire/dlt_19_stormtrooper.card.png',
        model = {
          mesh = 'https://assets.swlegion.dev/upgrades/empire/dlt_19_stormtrooper.obj',
          texture = 'https://assets.swlegion.dev/upgrades/empire/dlt_19_stormtrooper.diffuse.jpg'
        }
      }
    }
  },

  RebelAlliance = {
    HeavyWeapon = {
      {
        name = 'Z-6 Trooper',
        card = 'https://assets.swlegion.dev/upgrades/rebels/z_6_trooper.card.png',
        model = {
          mesh = 'https://assets.swlegion.dev/upgrades/rebels/z_6_trooper.obj',
          texture = 'https://assets.swlegion.dev/upgrades/rebels/z_6_trooper.diffuse.jpg'
        }
      }
    }
  }
}

--- Data table for a unit.
--
-- @field name Name of the unit (such as 'Stormtroopers').
-- @field models A list of tables of the mesh/texture for individual minis.
-- @table UnitData

--- Returns the unit data for the provided arguments.
--
-- @param args A table with the fields `faction`, `rank`, and `name`.
--
-- @usage
-- findUnit({
--   faction = 'GalacticEmpire',
--   rank    = 'Corps',
--   name    = 'Stormtroopers',
-- })
--
-- @treturn @{UnitData}
function findUnit(args)
  return _findUnit(args.faction, args.rank, args.name)
end

function _findUnit(faction, rank, name)
  local data = _UNITS[faction][rank]
  for _, unit in ipairs(data) do
    if unit.name == name then
      return unit
    end
  end
end

--- Data table for an upgrade.
--
-- @field name Name of the upgrade (such as 'DLT-19 Stormtrooper').
-- @field model A table of the mesh/texture if it has a mini.
-- @table UpgradeData

--- Returns the upgrade data for the provided arguments.
--
-- @param args A table with the fields `faction`, `rank`, and `name`.
--
-- @usage
-- findUpgrade({
--   faction = 'GalacticEmpire',
--   slot    = 'HeavyWeapon',
--   name    = 'DLT-19 Stormtrooper',
-- })
--
-- @treturn @{UpgradeData}
function findUpgrade(args)
  return _findUpgrade(args.faction, args.slot, args.name)
end

function _findUpgrade(faction, slot, name)
  local data = _UPGRADES[faction][slot]
  for _, upgrade in ipairs(data) do
    if upgrade.name == name then
      return upgrade
    end
  end
end
