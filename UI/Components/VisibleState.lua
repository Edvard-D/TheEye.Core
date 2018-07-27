TheEyeAddon.UI.Components.VisibleState = {}
local this = TheEyeAddon.UI.Components.VisibleState
local inherited = TheEyeAddon.UI.Components.Elements.ListenerValueChangeHandlers.KeyStateFunctionCaller

local EnabledStateFunctionCallerSetup = TheEyeAddon.UI.Components.Elements.ListenerValueChangeHandlers.EnabledStateFunctionCaller.Setup
local SendCustomEvent = TheEyeAddon.Events.Coordinator.SendCustomEvent


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
}

#UIOBJECT#TEMPLATE#DisplayData#
{
    factory = #TheEyeAddon.UI.Factories#NAME#
    DimensionTemplate =
    {
        PointSettings =
        {
            point = #POINT#
            relativePoint = #POINT#
            offsetY = #INT#
        }
    }
}
]]


--[[ SETUP
    instance
    uiObject                    UIObject
]]
function this.Setup(
    instance,
    uiObject
)

    inherited.Setup(
        instance,
        uiObject,
        this.Show,
        this.Hide
    )
    
    -- EnabledStateFunctionCaller
    instance.OnEnable = this.OnEnable
    instance.OnDisable = this.OnDisable

    instance.EnabledStateFunctionCaller = {}
    EnabledStateFunctionCallerSetup(
        instance.EnabledStateFunctionCaller,
        uiObject,
        instance
    )
end

function this:OnEnable()
    self:Activate()
end

function this:OnDisable()
    self:Deactivate()
end

function this:Show()
    --print ("SHOW    " .. self.UIObject.key) -- DEBUG
    SendCustomEvent("UIOBJECT_FRAME_USER_REGISTERED", self.UIObject)
    SendCustomEvent("UIOBJECT_SHOWN", self.UIObject)
end

function this:Hide()
    --print ("HIDE    " .. self.UIObject.key) -- DEBUG
    SendCustomEvent("UIOBJECT_FRAME_USER_DEREGISTERED", self.UIObject)
    SendCustomEvent("UIOBJECT_HIDDEN", self.UIObject)
end