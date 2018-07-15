local TheEyeAddon = TheEyeAddon
TheEyeAddon.Events.Evaluators.SPELL_USABLE_CHANGED = {}
local this = TheEyeAddon.Events.Evaluators.SPELL_USABLE_CHANGED
this.name = "SPELL_USABLE_CHANGED"

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
}

function this:CalculateCurrentValue(inputValues)
    return IsUsableSpell(inputValues[1])
end

function this:Evaluate(inputGroup, event)
    local isUseable = self:CalculateCurrentValue(inputGroup.inputValues)
    if inputGroup.currentValue ~= isUseable then
        inputGroup.currentValue = isUseable
        return true, this.name, isUseable
    end
end