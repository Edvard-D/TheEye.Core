local TheEyeAddon = TheEyeAddon
TheEyeAddon.UI.Components.Elements.ListenerValueChangeHandlers.StateFunctionCaller = {}
local this = TheEyeAddon.UI.Components.Elements.ListenerValueChangeHandlers.StateFunctionCaller
local inherited = TheEyeAddon.UI.Components.Elements.ListenerValueChangeHandlers.Base

local SimpleStateSetup = TheEyeAddon.UI.Components.Elements.ValueHandlers.SimpleState.Setup
local ValueSetterSetup = TheEyeAddon.UI.Components.Elements.ListenerGroups.ValueSetter.Setup


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
}
]]


--[[ SETUP
    instance
    uiObject                    UIObject
    listener                    #LISTENER#
    onStateChange               function(#BOOL#)
    stateListener               { function On#trueFunctionName#(), function On#falseFunctionName#() }
    trueFunctionName            #STRING#
    falseFunctionName           #STRRING#
]]
function this.Setup(
    instance,
    uiObject,
    listener,
    onStateChange,
    stateListener,
    trueFunctionName,
    falseFunctionName
)

    instance.ValueHandler = {}
    SimpleStateSetup(
        instance.ValueHandler,
        uiObject,
        instance
    )

    instance.ListenerGroup =
    {
        Listeners =
        {
            listener
        }
    }
    ValueSetterSetup(
        instance.ListenerGroup,
        uiObject,
        instance.ValueHandler
    )

    inherited.Setup(
        instance,
        uiObject,
        instance.ValueHandler,
        instance.ListenerGroup
    )

    instance.OnStateChange = onStateChange
    instance.StateListener = stateListener
    instance.stateFunctionNames =
    {
        [true] = trueFunctionName,
        [false] = falseFunctionName
    }
end

function this:OnStateChange(state)
    self.StateListener[self.stateFunctionNames[state]](self.stateListener)
end