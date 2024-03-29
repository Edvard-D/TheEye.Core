TheEye.Core.Evaluators.PLAYER_SPELL_USEABLE_CHANGED = {}
local this = TheEye.Core.Evaluators.PLAYER_SPELL_USEABLE_CHANGED

local IsUsableSpell = IsUsableSpell


--[[ #this#TEMPLATE#
{
    inputValues = { #LABEL#SpellID# #INT#, }
}
]]


this.reevaluateEvents =
{
    SPELL_UPDATE_USABLE = true,
}
this.gameEvents =
{
    "SPELL_UPDATE_USABLE",
    "UNIT_SPELLCAST_SUCCEEDED",
}


local function CalculateCurrentValue(inputValues)
    return IsUsableSpell(inputValues[1])
end

function this:InputGroupSetup(inputGroup)
    inputGroup.currentValue = CalculateCurrentValue(inputGroup.inputValues)
end

function this:GetKey(event, ...)
    local unit, _, spellID = ...
    
    if unit ~= "player" then
        return
    end

    return table.concat({ spellID })
end

function this:Evaluate(inputGroup, event)
    local isUseable = CalculateCurrentValue(inputGroup.inputValues)
    if inputGroup.currentValue ~= isUseable then
        inputGroup.currentValue = isUseable
        return true, this.key
    end
end