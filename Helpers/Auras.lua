TheEye.Core.Helpers.Auras = {}
local this = TheEye.Core.Helpers.Auras

local auraFilters = TheEye.Core.Data.auraFilters
local GetPropertiesOfType = TheEye.Core.Managers.Icons.GetPropertiesOfType
local IconsGetFiltered = TheEye.Core.Managers.Icons.GetFiltered
local select = select
local table = table
local UnitAura = UnitAura


function this.UnitAurasGet(unit, filter)
    local auras = {}
    local i = 0

    while true do
        i = i + 1
        local auraValues = { UnitAura(unit, i, filter) }

        if auraValues[1] == nil then
            return auras
        end

        table.insert(auras, auraValues)
    end

    return auras
end

function this.UnitAuraSpellIDsGet(unit, filter)
    local spellIDs = {}
    local i = 0

    while true do
        i = i + 1
        local spellID = select(10, UnitAura(unit, i, filter))
        
        if spellID == nil then
            return spellIDs
        end

        if table.hasvalue(spellIDs, spellID) == false then
            table.insert(spellIDs, spellID)
        end
    end

    return spellIDs
end

function this.UnitAuraGetBySpellID(sourceUnitExpected, destUnit, spellIDExpected)
    local filter = "HELPFUL"
    local i = 0

    local icons = IconsGetFiltered(
    {
        {
            {
                type = "OBJECT_ID",
                value = spellIDExpected,
            },
        },
    })

    if #icons > 0 then
        local CATEGORY = GetPropertiesOfType(icons[1], "CATEGORY")
        if CATEGORY.value == "DAMAGE" then
            filter = "HARMFUL"
        end
    end

    while true do
        i = i + 1
        local auraValues = { UnitAura(destUnit, i, filter) }
        local spellID = auraValues[10]

        if spellID ~= nil then
            local sourceUnit = auraValues[7]
            if spellID == spellIDExpected
                and (sourceUnitExpected == "_" or sourceUnit == sourceUnitExpected)
                then
                
                return auraValues
            end
        else
            return nil
        end
    end
end

function this.UnitAuraDurationGet(sourceUnit, destUnit, spellIDExpected)
    local auraData = this.UnitAuraGetBySpellID(sourceUnit, destUnit, spellIDExpected)
    
    local remainingTime = 0
    if auraData ~= nil then
        remainingTime = auraData[6] - GetTime()
        if remainingTime < 0 then
            remainingTime = 0
        end
    end
    
    return remainingTime
end