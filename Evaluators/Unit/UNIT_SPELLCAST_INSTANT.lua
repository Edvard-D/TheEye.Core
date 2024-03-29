TheEye.Core.Evaluators.UNIT_SPELLCAST_INSTANT = {}
local this = TheEye.Core.Evaluators.UNIT_SPELLCAST_INSTANT

local GetTime = GetTime
local select = select
local table = table
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo


--[[ #this#TEMPLATE#
{
    inputValues =
    {
        #LABEL#Unit# #UNIT#
        #LABEL#Spell ID# #SPELL#ID#
    }
}
]]


this.reevaluateEvents =
{
    PLAYER_TARGET_CHANGED = true,
}
this.gameEvents =
{
    "PLAYER_TARGET_CHANGED",
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_SUCCEEDED"
}


function this:InputGroupSetup(inputGroup)
    inputGroup.castTimestamp = 0
end

function this:GetKey(event, ...)
    local unit, _, spellID = ...
    return table.concat({ unit, spellID })
end

function this:Evaluate(inputGroup, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        local retrievedSpellID = select(9, UnitCastingInfo(inputGroup.inputValues[1]))
        if retrievedSpellID == nil then
            retrievedSpellID = select(8, UnitChannelInfo(inputGroup.inputValues[1]))
        end

        inputGroup.isCasting = retrievedSpellID == inputGroup.inputValues[2]
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        if inputGroup.isCasting ~= true then
            inputGroup.castTimestamp = GetTime()
            return true, this.key
        end
        inputGroup.isCasting = false
    elseif event == "UNIT_SPELLCAST_START" then
        inputGroup.isCasting = true
    else -- UNIT_SPELLCAST_STOP
        inputGroup.isCasting = false
    end

    return false
end