TheEye.Core.UI.Elements.ListenerValueChangeHandlers.KeyStateFunctionCaller = {}
local this = TheEye.Core.UI.Elements.ListenerValueChangeHandlers.KeyStateFunctionCaller
local inherited = TheEye.Core.UI.Elements.ListenerValueChangeHandlers.Base

local IntegerKeyStateSetup = TheEye.Core.UI.Elements.ValueHandlers.IntegerKeyState.Setup
local StateBasedIntChangerSetup = TheEye.Core.UI.Elements.ListenerGroups.StateBasedIntChanger.Setup


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
    ValueHandler = #TheEye.Core.UI.Elements.ValueHandlers.IntegerKeyState#TEMPLATE#
    ListenerGroup = #TheEye.Core.UI.Elements.ListenerGroups.StateBasedIntChanger#TEMPLATE#
}
]]


--[[ SETUP
    instance
    onValidKey                  function()
    onInvalidKey                function()
]]
function this.Setup(
    instance,
    onValidKey,
    onInvalidKey
)
    
    IntegerKeyStateSetup(
        instance.ValueHandler,
        instance
    )

    if instance.ListenerGroup ~= nil then
        StateBasedIntChangerSetup(
            instance.ListenerGroup,
            instance.ValueHandler
        )
    end

    inherited.Setup(
        instance,
        instance.ValueHandler,
        instance.ListenerGroup
    )

    instance.OnValidKey = onValidKey
    instance.OnInvalidKey = onInvalidKey
    
    instance.OnStateChange = this.OnStateChange
end

function this:OnStateChange(state)
    if state == true then
        self:OnValidKey()
    else
        self:OnInvalidKey()
    end
end