TheEye.Core.Evaluators.UIOBJECT_WITH_PARENT_VISIBLE_CHANGED = {}
local this = TheEye.Core.Evaluators.UIOBJECT_WITH_PARENT_VISIBLE_CHANGED


--[[ #this#TEMPLATE#
{
    inputValues = { #LABEL#Parent UIObject# #UIOBJECT#KEY# }
}
]]


this.customEvents =
{
    "UIOBJECT_HIDDEN",
    "UIOBJECT_SHOWN",
}


function this:GetKey(event, childUIObject)
    local childComponent = childUIObject.Child
    if childComponent == nil then
        return nil
    end

    return childComponent.parentKey
end

function this:Evaluate(inputGroup, event, childUIObject)
    inputGroup.currentValue = childUIObject
    return true, this.key
end