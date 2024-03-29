TheEye.Core.UI.Elements.Listeners.Base = {}
local this = TheEye.Core.UI.Elements.Listeners.Base
local inherited = TheEye.Core.UI.Elements.Base

local Comparisons = TheEye.Core.Helpers.Comparisons
local DebugLogEntryAdd = TheEye.Core.Managers.Debug.LogEntryAdd
local ListenerRegister = TheEye.Core.Managers.Evaluators.ListenerRegister
local ListenerDeregister = TheEye.Core.Managers.Evaluators.ListenerDeregister


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
    eventEvaluatorKey = #EVALUATOR#NAME#
    inputValues = { #EVALUATOR#TEMPLATE#inputValues# }
    #OPTIONAL#priority = #INT#
    #OPTIONAL#isInternal = #BOOL#
    #OPTIONAL#comparisonValues =
    {
        type = TheEye.Core.Helpers.Comparisons#NAME#
        TheEye.Core.Helpers.Comparisons#NAME#TEMPLATE#
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
    instance.isActive = false

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
    if self.isActive == true then
        return
    end
    self.isActive = true

    self:Register()
end

function this:Deactivate()
    if self.isActive == false then
        return 
    end
    self.isActive = false

    self:Deregister()
    self.comparisonState = nil
end

function this:Notify(event, inputGroup)
    DebugLogEntryAdd("TheEye.Core.UI.Elements.Listeners.Base", "Notify", self.UIObject, self.Component, event, inputGroup.key, inputGroup.currentValue)
    
    if self.comparisonValues == nil then
        self.NotificationHandler:OnNotify(self, event, inputGroup.currentValue, inputGroup)
    else
        local comparisonState = Comparisons[self.comparisonValues.type](
            inputGroup.currentValue, self.comparisonValues)
        if (self.comparisonState ~= comparisonState and self.comparisonState ~= nil)
            or (self.comparisonState == nil and comparisonState == true)
            then
            self.comparisonState = comparisonState
            self.NotificationHandler:OnNotify(self, event, comparisonState, inputGroup)
        end
    end
end

function this:Register()
    ListenerRegister(self.eventEvaluatorKey, self)
end

function this:Deregister()
    ListenerDeregister(self.eventEvaluatorKey, self)
end