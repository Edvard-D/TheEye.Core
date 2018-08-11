TheEyeAddon.Events.Evaluators.UIOBJECT_COOLDOWN_CHANGED = {}
local this = TheEyeAddon.Events.Evaluators.UIOBJECT_COOLDOWN_CHANGED
this.name = "UIOBJECT_COOLDOWN_CHANGED"


--[[ #this#TEMPLATE#
{
    inputValues = { #LABEL#UIObject Key# #UIOBJECT#KEY# }
}
]]


this.customEvents =
{
    "UIOBJECT_COOLDOWN_SHOWN",
    "UIOBJECT_COOLDOWN_HIDDEN",
}


local function CalculateCurrentValue(uiObject)
    return uiObject.ReadySoonAlert.ValueHandler.state or false
end

function this:InputGroupSetup(inputGroup)
    local uiObject = TheEyeAddon.UI.Objects.Instances[inputGroup.inputValues[1]]
    inputGroup.currentValue = CalculateCurrentValue(uiObject)
end

function this:GetKey(event, uiObject)
    return uiObject.key
end

function this:Evaluate(inputGroup, event, uiObject)
    local isVisible = CalculateCurrentValue(uiObject)

    if inputGroup.currentValue ~= isVisible then
        inputGroup.currentValue = isVisible
        return true, this.name, isVisible
    end
end