TheEye.Core.Managers.Evaluators = {}
local this = TheEye.Core.Managers.Evaluators

local EventsRegister = TheEye.Core.Managers.Events.Register
local EventsDeregister = TheEye.Core.Managers.Events.Deregister
local DebugLogEntryAdd = TheEye.Core.Managers.Debug.LogEntryAdd
local Evaluators = TheEye.Core.Evaluators
local pairs = pairs
local select = select
local table = table


-- Setup
local function EvaluatorSetup(evaluator, evaluatorKey)
    evaluator.key = evaluatorKey
    evaluator.OnEvent = this.OnEvent
    EventsRegister(evaluator)
end

-- Initialization
function this.Initialize()
    for key, evaluator in pairs(Evaluators) do
        if evaluator.isAlwaysActive == true then
            EvaluatorSetup(evaluator, key)
            
            if evaluator.SetupListeningTo ~= nil then
                evaluator:SetupListeningTo()
            end
        end
    end
end

-- Get
local function InputGroupGet(evaluator, inputValues)
    if evaluator.InputGroups == nil then
        evaluator.InputGroups = {}
    end

    local inputGroupKey
    if inputValues ~= nil then
        inputGroupKey = table.concat(inputValues)
    else
        inputGroupKey = "default"
    end

    if evaluator.InputGroups[inputGroupKey] == nil then
        evaluator.InputGroups[inputGroupKey] =
        {
            key = inputGroupKey,
            inputValues = inputValues,
        }
    end

    return evaluator.InputGroups[inputGroupKey]
end

local function InputGroupGetListeners(inputGroup)
    if inputGroup.listeners == nil then
        inputGroup.listeners = {}
    end

    return inputGroup.listeners
end

-- Listener Count
local function EvaluatorIncreaseListenerCount(evaluator, evaluatorKey)
    if evaluator.listenerCount == nil then 
        evaluator.listenerCount = 0
    end

    evaluator.listenerCount = evaluator.listenerCount + 1

    if evaluator.isAlwaysActive == true then
        return
    end

    if evaluator.listenerCount == 1 then -- If listenerCount was 0 before
        EvaluatorSetup(evaluator, evaluatorKey)
    end
end

local function InputGroupIncreaseListenerCount(evaluator, inputGroup, listener)
    if inputGroup.listenerCount == nil then
        inputGroup.listenerCount = 0
    end

    inputGroup.listenerCount = inputGroup.listenerCount + 1

    if inputGroup.listenerCount == 1 then -- If listenerCount was 0 before
        inputGroup.Evaluator = evaluator
        inputGroup.inputValues = listener.inputValues
    
        if evaluator.isAlwaysActive ~= true
            and evaluator.SetupListeningTo ~= nil
            and inputGroup.ListeningTo == nil
            then
            evaluator:SetupListeningTo(inputGroup)
        end
    
        if evaluator.InputGroupSetup ~= nil then
            evaluator:InputGroupSetup(inputGroup)
        end
    end
end

local function EvaluatorDecreaseListenerCount(evaluator)
    evaluator.listenerCount = evaluator.listenerCount - 1

    if evaluator.isAlwaysActive == true then
        return
    end

    if evaluator.listenerCount == 0 then -- If the listenerCount was greater than 0 before
        EventsDeregister(evaluator)
    end
end

local function InputGroupDecreaseListenerCount(evaluator, inputGroup)
    inputGroup.listenerCount = inputGroup.listenerCount - 1

    if inputGroup.listenerCount == 0 and inputGroup.ListeningTo ~= nil then -- If the listenerCount was greater than 0 before
        this.InputGroupDeregisterListeningTo(inputGroup)
    end
end

-- Register/Deregister
function this.ListenerRegister(evaluatorKey, listener)
    local evaluator = Evaluators[evaluatorKey]
    local inputGroup = InputGroupGet(evaluator, listener.inputValues)
    local listeners = InputGroupGetListeners(inputGroup)
    
    DebugLogEntryAdd("TheEye.Core.Managers.Evaluators", "ListenerRegister", listener.UIObject, listener.Component, evaluatorKey)

    if listener.priority == nil then
        listener.priority = math.huge
    end

    table.insert(listeners, listener)
    table.sort(listeners, function(a,b)
        return (a.isInternal and not b.isInternal)
            or (a.isInternal == b.isInternal and a.priority < b.priority)
    end)

    listener.isListening = true
    EvaluatorIncreaseListenerCount(evaluator, evaluatorKey)
    InputGroupIncreaseListenerCount(evaluator, inputGroup, listener)

    if inputGroup.currentValue == true
        or (inputGroup.currentValue ~= nil and type(inputGroup.currentValue) ~= "boolean")
        then
        listener:Notify(evaluatorKey, inputGroup)
    end
end

function this.ListenerDeregister(evaluatorKey, listener)
    local evaluator = Evaluators[evaluatorKey]
    local inputGroup = InputGroupGet(evaluator, listener.inputValues)
    local listeners = InputGroupGetListeners(inputGroup)
    
    DebugLogEntryAdd("TheEye.Core.Managers.Evaluators", "ListenerDeregister", listener.UIObject, listener.Component, evaluatorKey)

    if listener.isListening == true then
        table.removevalue(listeners, listener)
        listener.isListening = false
        EvaluatorDecreaseListenerCount(evaluator)
        InputGroupDecreaseListenerCount(evaluator, inputGroup)
    end
end

-- Listening To: handling of Evaluators that are listening to an Evaluator
function this.EvaluatorRegisterListeningTo(evaluator, listener)
    listener.Notify = this.Notify
    listener.evaluator = evaluator

    this.ListenerRegister(listener.listeningToKey, listener)
end

function this.InputGroupRegisterListeningTo(inputGroup, listener)
    if inputGroup.ListeningTo == nil then
        inputGroup.ListeningTo = {}
    end

    if inputGroup.ListeningTo[listener] == nil then
        inputGroup.ListeningTo[listener] = listener
        listener.Notify = this.Notify
        listener.Evaluator = inputGroup.Evaluator
    end

    this.ListenerRegister(listener.listeningToKey, listener)
end

function this.InputGroupDeregisterListeningTo(inputGroup)
    local listeningTo = inputGroup.ListeningTo
    for i = 1, #listeningTo do
        local listener = listeningTo[i]
        this.ListenerDeregister(listener.listeningToKey, listener)
    end
end

-- Event Evaluation
local function ListenersNotify(inputGroup, shouldSend, event)
    DebugLogEntryAdd("TheEye.Core.Managers.Evaluators", "ListenersNotify", nil, nil, event, inputGroup.Evaluator.key, inputGroup.key, inputGroup.currentValue)
    
    if shouldSend == true then
        -- It's necessary to create a seperate list of references to listeners as items from inputGroup.listeners may
        -- be removed based on a listener being notified. This can result in a listener later in the list never being
        -- notified, as the size of the list gets reduced by 1 when a listener is removed.
        local listeners = {}
        for i = 1, #inputGroup.listeners do
            table.insert(listeners, inputGroup.listeners[i])
        end
        
        for i = 1, #listeners do
            local listener = listeners[i]

            if listener ~= nil and listener.isListening == true and listener.Notify ~= nil then
                DebugLogEntryAdd("TheEye.Core.Managers.Evaluators", "ListenersNotify: listener notified", listener.UIObject, listener.Component, i, event, inputGroup.Evaluator.key, inputGroup.key, inputGroup.currentValue)
                
                listener:Notify(event, inputGroup)
            end
        end
    end
end

local function Evaluate(evaluator, inputGroup, event, ...)
    ListenersNotify(inputGroup, evaluator:Evaluate(inputGroup, event, ...))
end

function this:Notify(...)
    self.evaluator:OnEvent(...)
end

function this:OnEvent(event, ...)
    if self.Preprocess ~= nil then
        self:Preprocess(event, ...)
    end

    if self.reevaluateEvents ~= nil and self.reevaluateEvents[event] ~= nil then
        for k,inputGroup in pairs(self.InputGroups) do -- @TODO change this to an array with a lookup table
            Evaluate(self, inputGroup, event, ...)
        end
    elseif self.GetKeys ~= nil then
        local inputGroupKeys = self:GetKeys(event, ...)
        for i = 1, #inputGroupKeys do
            local inputGroup = self.InputGroups[inputGroupKeys[i]]
            if inputGroup ~= nil then
                Evaluate(self, inputGroup, event, ...)
            end
        end
    else
        local inputGroup = self.InputGroups[self:GetKey(event, ...)]
        if inputGroup ~= nil then
            Evaluate(self, inputGroup, event, ...)
        end
    end
end