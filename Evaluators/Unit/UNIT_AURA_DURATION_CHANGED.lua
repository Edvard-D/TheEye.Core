TheEye.Core.Evaluators.UNIT_AURA_DURATION_CHANGED = {}
local this = TheEye.Core.Evaluators.UNIT_AURA_DURATION_CHANGED

local GetTime = GetTime
local InputGroupDurationTimerStart = TheEye.Core.Helpers.Timers.InputGroupDurationTimerStart
local InputGroupRegisterListeningTo = TheEye.Core.Managers.Evaluators.InputGroupRegisterListeningTo
local select = select
local StartEventTimer = TheEye.Core.Helpers.Timers.StartEventTimer
local table = table
local UnitAuraDurationGet = TheEye.Core.Helpers.Auras.UnitAuraDurationGet
local updateRate = 0.5
local unpack = unpack


--[[ #this#TEMPLATE#
{
    inputValues =
    {
        #OPTIONAL# #LABEL#Source Unit# #UNIT#
        #LABEL#Destination Unit# #UNIT#
        #LABEL#Spell ID# #SPELL#ID#
    }
}
]]


this.reevaluateEvents =
{
    PLAYER_TARGET_CHANGED = true,
}
this.gameEvents =
{
    "PLAYER_TARGET_CHANGED",
}
this.customEvents =
{
    "AURA_DURATION_TIMER_END",
}
local combatLogEvents =
{
    "SPELL_AURA_APPLIED",
    "SPELL_AURA_BROKEN",
    "SPELL_AURA_BROKEN_SPELL",
    "SPELL_AURA_REFRESH",
    "SPELL_AURA_REMOVED",
}

function this:SetupListeningTo(inputGroup)
    for i = 1, #combatLogEvents do
        InputGroupRegisterListeningTo(inputGroup,
        {
            listeningToKey = "COMBAT_LOG",
            evaluator = this,
            inputValues = { combatLogEvents[i], inputGroup.inputValues[1], inputGroup.inputValues[2] }
        })
    end
end

local function TimerStart(inputGroup, timerLength)
    InputGroupDurationTimerStart(inputGroup, timerLength, "AURA_DURATION_TIMER_END", inputGroup.inputValues)
end

local function CalculateCurrentValue(inputValues)
    local sourceUnitExpected, destUnit, spellIDExpected = unpack(inputValues)
    
    return UnitAuraDurationGet(sourceUnitExpected, destUnit, spellIDExpected)
end

function this:InputGroupSetup(inputGroup)
    inputGroup.currentValue = CalculateCurrentValue(inputGroup.inputValues)
    TimerStart(inputGroup, inputGroup.currentValue)
end

function this:GetKey(event, ...)
    if event == "AURA_DURATION_TIMER_END" then
        local inputValues = select(2, ...)
        return table.concat(inputValues)
    else
        local inputGroup = ...
        local eventData = inputGroup.eventData

        local sourceUnit = eventData["sourceUnit"]
        local destUnit = eventData["destUnit"]
        local spellID = eventData["spellID"]

        return table.concat({ sourceUnit, destUnit, spellID })
    end
end

function this:Evaluate(inputGroup, event)
    local remainingTime = CalculateCurrentValue(inputGroup.inputValues)

    if inputGroup.currentValue ~= remainingTime then
        TimerStart(inputGroup, updateRate)
        inputGroup.currentValue = remainingTime
        return true, this.key
    end
end