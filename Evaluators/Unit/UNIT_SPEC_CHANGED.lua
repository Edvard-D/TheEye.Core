TheEye.Core.Evaluators.UNIT_SPEC_CHANGED = {}
local this = TheEye.Core.Evaluators.UNIT_SPEC_CHANGED

local GetInspectSpecialization = GetInspectSpecialization
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local select = select
local table = table


--[[ #this#TEMPLATE#
{
    inputValues =
    {
        #LABEL#Unit# #UNIT#
        #LABEL#Spec ID# #SPEC#ID#
    }
}
]]


this.reevaluateEvents =
{
    PLAYER_SPECIALIZATION_CHANGED = true,
    PLAYER_TARGET_CHANGED = true,
}
this.gameEvents =
{
    "PLAYER_SPECIALIZATION_CHANGED",
    "PLAYER_TARGET_CHANGED"
}


local function CalculateCurrentValue(inputValues)
    local specID

    if inputValues[1] == "player" then
        this.playerSpec = select(1, GetSpecializationInfo(GetSpecialization()))
        specID = this.playerSpec
    else
        specID = GetInspectSpecialization(inputValues[1])
    end

    return inputValues[2] == specID
end

function this:InputGroupSetup(inputGroup)
    inputGroup.currentValue = CalculateCurrentValue(inputGroup.inputValues)
end

function this:Evaluate(inputGroup, event)
    local isSpec = CalculateCurrentValue(inputGroup.inputValues)

    if inputGroup.currentValue ~= isSpec then
        inputGroup.currentValue = isSpec
        return true, this.key
    end
end