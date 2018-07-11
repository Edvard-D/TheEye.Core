local TheEyeAddon = TheEyeAddon
TheEyeAddon.UI.Components.Elements.ListenerGroups.StateBasedIntChanger = {}
local this = TheEyeAddon.UI.Components.Elements.ListenerGroups.StateBasedIntChanger
local inherited = TheEyeAddon.UI.Components.Elements.ListenerGroups.ValueChanger

local select = select


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
}
]]


--[[ #SETUP#
    instance
    UIObject                    UIObject
    ValueHandler                ValueHandler
]]
function this:Setup(
    instance,
    UIObject,
    ValueHandler
)

    inherited:Setup(
        instance,
        UIObject,
        ListenerWithIntSetup,
        ValueHandler,
        this.ChangeValueByState
    )
end

function this:ChangeValueByState(listener, ...)
    local state = select(2, ...)

    if state == true then
        return listener.value
    else
        return listener.value * -1
    end
end