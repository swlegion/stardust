--- This disk represents all of the "data" in the game (e.g. giant JSON).
--
-- In future versions of the prototype, this will be downloaded asynchronously
-- and cached in onSave instead of requiring everything to be inlined here.
--
-- @module Data_Controller

_DATA = {
  GalacticEmpire = {
    Corps = {
      {
        name = 'Stormtroopers',
        base = 'Small',
        rank = 'Corps',
        models = {
          {
            mesh = "https://assets.swlegion.dev/units/empire/stormtrooper-1.obj",
            texture = "http://localhost:8080/units/empire/stormtrooper.jpg"
          },

          {
            mesh = "http://localhost:8080/units/empire/stormtrooper.2.obj"
          },

          {
            mesh = "http://localhost:8080/units/empire/stormtrooper.3.obj"
          },

          {
            mesh = "http://localhost:8080/units/empire/stormtrooper.4.obj"
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
          models = {
            {
              mesh = "http://localhost:8080/units/rebels/rebel_trooper.1.obj",
              texture = "http://localhost:8080/units/rebels/rebel_trooper.jpg"
            },

            {
              mesh = "http://localhost:8080/units/rebels/rebel_trooper.2.obj"
            },

            {
              mesh = "http://localhost:8080/units/rebels/rebel_trooper.3.obj"
            },

            {
              mesh = "http://localhost:8080/units/rebels/rebel_trooper.4.obj"
            }
          }
        }
      }
    },
}

--- Data table for a unit.
--
-- @field name Name of the unit (such as "Stormtroopers").
-- @field models A list of tables of the mesh/texture for individual minis.
-- @table data

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
-- @treturn @{data} A table with the `name` and `models` for the minis.
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