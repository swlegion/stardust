--- This disk represents all of the "data" in the game (e.g. giant JSON).
--
-- @module Data_Controller
--
-- In future versions of the prototype, this will be downloaded asynchronously
-- and cached in onSave instead of requiring everything to be inlined here.
--
-- ```
-- FACTION > RANK > units[]
--   name
--   models[]
--     mesh
--     texture
-- ```
_DATA = {
  GalacticEmpire = {
    Corps = {
      {
        name = 'Stormtroopers',
        models = {
          {
            mesh = "https://assets.swlegion.dev/units/empire/stormtrooper-1.obj",
            texture = "https://assets.swlegion.dev/units/empire/stormtrooper.jpg"
          },

          {
            mesh = "https://assets.swlegion.dev/units/empire/stormtrooper.2.obj"
          },

          {
            mesh = "https://assets.swlegion.dev/units/empire/stormtrooper.3.obj"
          },

          {
            mesh = "https://assets.swlegion.dev/units/empire/stormtrooper.4.obj"
          }
          }
        }
      }
    },

    RebelAlliance = {
      Corps = {
        {
          name = 'Rebel Troopers',
          models = {
            {
              mesh = "https://assets.swlegion.dev/units/rebels/rebel_trooper.1.obj",
              texture = "https://assets.swlegion.dev/units/rebels/rebel_trooper.jpg"
            },

            {
              mesh = "https://assets.swlegion.dev/units/rebels/rebel_trooper.2.obj"
            },

            {
              mesh = "https://assets.swlegion.dev/units/rebels/rebel_trooper.3.obj"
            },

            {
              mesh = "https://assets.swlegion.dev/units/rebels/rebel_trooper.4.obj"
            }
          }
        }
      }
    },
}

--- Returns the unit data for the provided arguments.
--
-- @param args A table with the fields `faction`, `rank`, and `name`.
--
-- @usage
-- ```
-- findUnit({
--   faction = 'GalacticEmpire',
--   rank    = 'Corps',
--   name    = 'Stormtroopers',
-- })
-- ```
--
-- @return A table with the `name` and `models` used to refer to the minis:
-- @usage
-- {
--   name = 'Stormtroopers',
--   models = {
--     -- Index 1 is always the Unit Leader.
--     {
--       mesh = '/link/to/mesh.obj',
--       texture = '/link/to/texture.jpg',
--     },
--
--     -- For non-leaders, `texture` can be omitted to use the leader's texture.
--     {
--       mesh = '/link/to/another-mesh.obj',
--     }
--   }
-- }
-- ```
function findUnit(args)
  return _findUnit(args.faction, args.rank, args.name)
end

function _findUnit(faction, rank, name)
  local data = _DATA[faction][rank]
  for _, unit in ipairs(data) do
    if unit.name == name then
      return unit
    end
  end
end
