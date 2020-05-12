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
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234540541711094/1DF94C3CDF022814179AFBA6D7521E6196760949",
            texture = "http://cloud-3.steamusercontent.com/ugc/785234540541711313/BBEF6E9A46755A4159DC6222AF0F8302792585D0/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234540541711529/FF076CE02269A8505CB8EFC06749196FFD446391/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234540541711653/C170DF086178164DC66188071D15E9EB36C9A742/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234540541711874/7E06BF6E8E18DD05BBBF10343614B47B8BEE9948/"
          }
          }
        }
      }
    },

    GalacticRepublic = {
      Corps = {
        {
          name = 'Phase I Clone Troopers',
          models = {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785236717873393043/33A6FEA07374DAC8EBB6CDD463B6C761DC765D03/",
            texture = "http://cloud-3.steamusercontent.com/ugc/785236717873393180/6359B491483DCD9B2641BA134DC4B92DE10E9D92/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785236717873393589/6AF627688F36D2049C1307BCB67A755FB27D51C5/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785236717873393727/8C4030EF9FEEB32E048567DC2EC38A1985E7C8C0/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785236717873457225/6382F0EA6E2DB0BC65921C3F4E5C97A84B422187/"
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
              mesh = "http://cloud-3.steamusercontent.com/ugc/785234780862746147/3F3A21962C4AC0DA0445024688BF580A144D3825/",
              texture = "http://cloud-3.steamusercontent.com/ugc/785234540540670236/6257E7A3CE86803490A8A0FAC7F81C281D700F52/"
            },

            {
              mesh = "http://cloud-3.steamusercontent.com/ugc/785234780862752262/41BD6AB8B17AB7449226A3D80EF186EB8ABA3952/"
            },

            {
              mesh = "http://cloud-3.steamusercontent.com/ugc/785234780862764799/98CBD8B4DD0C08CFA01A8E6C8B5A70A137804EAB/"
            },

            {
              mesh = "http://cloud-3.steamusercontent.com/ugc/785234780862755846/CD522BCA5D6E918E13A3FF593D7212FF4B0E79CA/"
            }
          }
        }
      }
    },

    SeparatistAlliance = {
      Corps = {
        name = 'B1 Battle Droids',
        models = {
          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234780869166347/AA861F86A0B74CF335533E425A6CBACB99395A09/",
            texture = "http://cloud-3.steamusercontent.com/ugc/785234780869166529/263C2AB95B1743539EC2CBDE40B0A14B1F5E5693/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234780869167061/48F42C02EDD970E6DE8E59B8601EF3E7F11C1742/",
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234780869167061/48F42C02EDD970E6DE8E59B8601EF3E7F11C1742/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234780869167318/DBC7863706A08B96020D3BFBE7A0C2C5689B7B08/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234780869166660/36AF6887F11FC70FF6AB75D0434EA79952C9E882/"
          },

          {
            mesh = "http://cloud-3.steamusercontent.com/ugc/785234780869167194/9ADFFD9AD608CBE3E9F6F61AB416E699A4156109/"
          }
        }
      }
    }
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