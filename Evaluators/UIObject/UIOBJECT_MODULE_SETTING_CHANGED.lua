TheEye.Core.Evaluators.UIOBJECT_MODULE_SETTING_CHANGED = {}
local this = TheEye.Core.Evaluators.UIOBJECT_MODULE_SETTING_CHANGED

local select = select
local table = table


--[[ #this#TEMPLATE#
{
    inputValues = { #LABEL#UIObject Key# #UIOBJECT#KEY# }
}
]]


this.reevaluateEvents =
{
    ADDON_LOADED = true
}
this.gameEvents =
{
    "ADDON_LOADED"
}
this.customEvents =
{
    "SETTING_CHANGED"
}


local function CalculateCurrentValue(inputValues)
    if TheEye.Core.Managers.Settings ~= nil
            and table.haskeyvalue(TheEye.Core.Managers.Settings.DisabledUIModules, inputValues[1]) == false then
        return true
    else
        return false
    end
end

function this:InputGroupSetup(inputGroup)
    inputGroup.currentValue = CalculateCurrentValue(inputGroup.inputValues)
end

function this:GetKey(event, ...)
    return select(1, ...) -- SETTING_CHANGED: moduleKey
end

function this:Evaluate(inputGroup)
    local isEnabled = CalculateCurrentValue(inputGroup.inputValues)

    if inputGroup.currentValue ~= isEnabled then
        inputGroup.currentValue = isEnabled
        return true, this.key
    end
end