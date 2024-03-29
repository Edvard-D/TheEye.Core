TheEye.Core.Evaluators.UNIT_CLASS_CHANGED = {}
local this = TheEye.Core.Evaluators.UNIT_CLASS_CHANGED

local select = select
local UnitClass = UnitClass


--[[ #this#TEMPLATE#
{
    inputValues =
    {
        #LABEL#Unit# #UNIT#
        #LABEL#Class ID# #CLASS#ID#
    }
}
]]


this.reevaluateEvents =
{
    PLAYER_TARGET_CHANGED = true
}
this.gameEvents =
{
    "PLAYER_TARGET_CHANGED"
}


local function CalculateCurrentValue(inputValues)
    local classIndex = select(3, UnitClass(inputValues[1]))
    return classIndex == inputValues[2]
end

function this:InputGroupSetup(inputGroup)
    inputGroup.currentValue = CalculateCurrentValue(inputGroup.inputValues)
end

function this:Evaluate(inputGroup)
    local isClass = CalculateCurrentValue(inputGroup.inputValues)

    if inputGroup.currentValue ~= isClass then
        inputGroup.currentValue = isClass
        return true, this.key
    end
end