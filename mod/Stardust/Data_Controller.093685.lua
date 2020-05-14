-- This disk represents all of the "data" in the game (e.g. giant JSON).
--
-- In future versions of the prototype, this will be downloaded asynchronously
-- and cached in onSave instead of requiring everything to be inlined here.

-- FACTION > RANK > units[]
--   name
--   models[]
--     mesh
--     texture
_DATA = {
  GalacticEmpire = {
    Corps = {
      {
        name = 'Stormtroopers',
        models = {
          {
            mesh = "http://localhost:8080/units/empire/stormtrooper-1.obj",
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

-- Returns the unit data for the provided table of arguments.
--   [1]: Faction
--   [2]: Rank
--   [3]: Name
function callFindUnit(args)
  return _findUnit(args[1], args[2], args[3])
end

function _findUnit(faction, rank, name)
  local data = _DATA[faction][rank]
  for _, unit in ipairs(data) do
    if unit.name == name then
      return unit
    end
  end
end
