TheEye.Core.UI.Elements.ListenerValueChangeHandlers.Base = {}
local this = TheEye.Core.UI.Elements.ListenerValueChangeHandlers.Base
local inherited = TheEye.Core.UI.Elements.Base


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
}
]]


--[[ SETUP
    instance
    valueHandler                ValueHandler
    listenerGroup               ListenerGroup
]]
function this.Setup(
    instance,
    valueHandler,
    listenerGroup
)

    inherited.Setup(
        instance
    )

    instance.ValueHandler = valueHandler
    instance.ListenerGroup = listenerGroup

    instance.Activate = this.Activate
    instance.Deactivate = this.Deactivate
end

function this:Activate()
    if self.ListenerGroup ~= nil then
        self.ListenerGroup:Activate()
    end
    self.ValueHandler:Activate()
end

function this:Deactivate()
    if self.ListenerGroup ~= nil then
        self.ListenerGroup:Deactivate()
    end
    self.ValueHandler:Deactivate()
end