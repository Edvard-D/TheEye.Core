local TheEyeAddon = TheEyeAddon
TheEyeAddon.Events.Evaluators.UIOBJECT_WITH_TAGS_VISIBILE_CHANGED = {}
local this = TheEyeAddon.Events.Evaluators.UIOBJECT_WITH_TAGS_VISIBILE_CHANGED
this.name = "UIOBJECT_WITH_TAGS_VISIBILE_CHANGED"

local UIObjectHasTags = TheEyeAddon.Tags.UIObjectHasTags


--[[ #this#TEMPLATE#
{
    inputValues = { #LABEL#Tags# #ARRAY#TAG# }
}
]]


this.reevaluateEvents =
{
    UIOBJECT_HIDDEN = true,
    UIOBJECT_SHOWN = true,
}
this.customEvents =
{
    "UIOBJECT_HIDDEN",
    "UIOBJECT_SHOWN",
}


function this:Evaluate(valueGroup, event, ...)
    local uiObject = ...
    local sendEvent = UIObjectHasTags(uiObject, valueGroup.inputValues, valueGroup.key)
    
    return sendEvent, this.name, uiObject
end