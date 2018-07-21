local TheEyeAddon = TheEyeAddon
TheEyeAddon.Events.Evaluators.PLAYER_TOTEM_ACTIVE_CHANGED = {}
local this = TheEyeAddon.Events.Evaluators.PLAYER_TOTEM_ACTIVE_CHANGED
this.name = "PLAYER_TOTEM_ACTIVE_CHANGED"

local InputGroupCooldownTimerStart = TheEyeAddon.Timers.InputGroupCooldownTimerStart
local GetTotemInfo = GetTotemInfo
local select = select


--[[ #this#TEMPLATE#
{
    inputValues =
    {
        #LABEL#Totem Name# #STRING#,
    }
}
]]


this.gameEvents = 
{
    "PLAYER_TOTEM_UPDATE",
}
this.customEvents =
{
    "PLAYER_TOTEM_TIMER_END",
}


local function CalculateCurrentValue(inputValues)
    for i=1,4 do
        local _, totemName = GetTotemInfo(i)
        if totemName == inputValues[1] then
            return true
        end
    end

    return false
end

function this:InputGroupSetup(inputGroup)
    inputGroup.currentValue = CalculateCurrentValue(inputGroup.inputValues)
end

function this:GetKey(event, ...)
    local totemName

    if event == "PLAYER_TOTEM_UPDATE" then
        local totemSlot = ...
        totemName = select(2, GetTotemInfo(totemSlot))
    else
        totemName = select(2, ...)
    end

    return totemName
end

function this:Evaluate(inputGroup, event, ...)
    local isActive
    local totemSlot

    if event == "PLAYER_TOTEM_UPDATE" then
        totemSlot = ...
        isActive, totemName, _, remainingTime = GetTotemInfo(totemSlot)
        InputGroupCooldownTimerStart(inputGroup, remainingTime, "PLAYER_TOTEM_TIMER_END", totemName)
    else -- PLAYER_TOTEM_TIMER_END
        isActive = false
    end

    if inputGroup.currentValue ~= isActive then
        inputGroup.currentValue = isActive
        return true, this.name, isActive
    end
end