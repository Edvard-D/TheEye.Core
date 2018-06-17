local TheEyeAddon = TheEyeAddon


-- SETUP/TEARDOWN
local function SetupListener(module, component, stateGroup, listener, handlerName)
    listener.module = module
    listener.component = component
    listener.stateGroup = stateGroup
    listener.OnStateChange = TheEyeAddon.UI.Components.OnStateChange
    TheEyeAddon.Events.Handlers:RegisterListener(handlerName, listener)
end

local function SetupStateGroup(module, component, stateGroup)
    for handlerName,v in pairs(stateGroup.StateListeners) do
        local listener = stateGroup.StateListeners[handlerName]
        SetupListener(module, component, stateGroup, listener, handlerName)
    end
end

local function TeardownStateGroup(stateGroup)
    for handlerName,v in pairs(stateGroup.StateListeners) do
        local listener = stateGroup.StateListeners[handlerName]
        TheEyeAddon.Events.Handlers:RegisterListener(handlerName, listener)
    end
end

function TheEyeAddon.UI.Components:SetupComponent(module, component)
    SetupStateGroup(module, component, component.StateGroups.Enabled)
end

function TheEyeAddon.UI.Components:TeardownComponent(component)
    for k,v in pairs(component.StateGroups) do
        TeardownStateGroup(component.StateGroups[k])
    end
end

-- STATE CHANGES
function TheEyeAddon.UI.Components:OnStateChange(stateListener, newState)
    local stateGroup = stateListener.stateGroup
    local previousState = stateGroup.currentState
    
    if newState == true then
        stateGroup.stateKey = stateGroup.stateKey + stateListener.stateValue
    else
        stateGroup.stateKey = stateGroup.stateKey - stateListener.stateValue
    end

    if stateGroup.validKeys[stateGroup.stateKey] ~= nil then
        stateGroup.currentState = true
        if previousState == false or previousState == nil then
            stateGroup:OnValidKey(stateListener.module, stateListener.component)
        end
    else
        stateGroup.currentState = false
        if previousState == true or previousState == nil then
            stateGroup:OnInvalidKey(stateListener.module, stateListener.component)
        end
    end
end

function TheEyeAddon.UI.Components:EnableComponent(module, component)
    SetupStateGroup(module, component, component.StateGroups.Visible)
end

function TheEyeAddon.UI.Components:DisableComponent(module, component)
    TeardownStateGroup(component.StateGroups.Visible)
    if component.StateGroups.Visible.currentState == true then
        TheEyeAddon.UI.Modules.Components:HideComponent(module, component)
    end
end

function TheEyeAddon.UI.Components:ShowComponent(module, component)
    component.frame = component.DisplayData.factory:Claim(module.frame, component.DisplayData)
    module:OnComponentVisibleChanged()
end

function TheEyeAddon.UI.Components:HideComponent(module, component)
    component.frame:Release()
    component.frame = nil
    module:OnComponentVisibleChanged()
end