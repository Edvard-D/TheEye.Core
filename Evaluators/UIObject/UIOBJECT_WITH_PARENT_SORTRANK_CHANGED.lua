TheEye.Core.Evaluators.UIOBJECT_WITH_PARENT_SORTRANK_CHANGED = {}
local this = TheEye.Core.Evaluators.UIOBJECT_WITH_PARENT_SORTRANK_CHANGED

local UIObjectHasTags = TheEye.Core.Tags.UIObjectHasTags


--[[ #this#TEMPLATE#
{
    inputValues = { #LABEL#Tags# #ARRAY#TAG# }
}
]]


this.customEvents =
{
    "UIOBJECT_SORTRANK_CHANGED",
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