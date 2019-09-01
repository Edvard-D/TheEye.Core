TheEyeAddon.UI.Elements.Listeners.Base = {}
local this = TheEyeAddon.UI.Elements.Listeners.Base
local inherited = TheEyeAddon.UI.Elements.Base

local Comparisons = TheEyeAddon.Helpers.Comparisons
local DebugLogEntryAdd = TheEyeAddon.Managers.Debug.LogEntryAdd
local ListenerRegister = TheEyeAddon.Managers.Evaluators.ListenerRegister
local ListenerDeregister = TheEyeAddon.Managers.Evaluators.ListenerDeregister


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
    eventEvaluatorKey = #EVALUATOR#NAME#
    inputValues = { #EVALUATOR#TEMPLATE#inputValues# }
    #OPTIONAL#priority = #INT#
    #OPTIONAL#isInternal = #BOOL#
    #OPTIONAL#comparisonValues =
    {
        type = TheEyeAddon.Helpers.Comparisons#NAME#
        TheEyeAddon.Helpers.Comparisons#NAME#TEMPLATE#
    }
}
]]


--[[ #SETUP#
    instance
    notificationHandler         { OnNotify:function(listener, ...) }
]]
function this.Setup(
    instance,
    notificationHandler
)

    inherited.Setup(
        instance
    )

    instance.NotificationHandler = notificationHandler

    instance.Activate = this.Activate
    instance.Deactivate = this.Deactivate
    instance.Notify = this.Notify
    instance.Register = this.Register
    instance.Deregister = this.Deregister

    if instance.inputValues ~= nil then
        local inputValues = instance.inputValues
        for i = 1, #inputValues do
            if inputValues[i] == "#SELF#UIOBJECT#KEY#" then
                inputValues[i] = instance.UIObject.key
                instance.isInternal = true
            end
        end
    end
end

function this:Activate()
    self:Register()
end

function this:Deactivate()
    self:Deregister()
    self.comparisonState = nil
end

function this:Notify(event, inputGroup)
    DebugLogEntryAdd("TheEyeAddon.UI.Elements.Listeners.Base", "Notify", self.UIObject, self.Component, event, inputGroup.key, inputGroup.currentValue)
    
    if self.comparisonValues == nil then
        self.NotificationHandler:OnNotify(self, event, inputGroup.currentValue)
    else
        local comparisonState = Comparisons[self.comparisonValues.type](
            inputGroup.currentValue, self.comparisonValues)
        if (self.comparisonState ~= comparisonState and self.comparisonState ~= nil)
            or (self.comparisonState == nil and comparisonState == true)
            then
            self.comparisonState = comparisonState
            self.NotificationHandler:OnNotify(self, event, comparisonState)
        end
    end
end

function this:Register()
    ListenerRegister(self.eventEvaluatorKey, self)
end

function this:Deregister()
    ListenerDeregister(self.eventEvaluatorKey, self)
end