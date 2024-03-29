TheEye.Core.Evaluators.PLAYER_SPELL_COOLDOWN_DURATION_CHANGED = {}
local this = TheEye.Core.Evaluators.PLAYER_SPELL_COOLDOWN_DURATION_CHANGED

local GetSpellCooldown = GetSpellCooldown
local GetTime = GetTime
local initialTimerLength = 0.01
local InputGroupDurationTimerStart = TheEye.Core.Helpers.Timers.InputGroupDurationTimerStart
local InputGroupRegisterListeningTo = TheEye.Core.Managers.Evaluators.InputGroupRegisterListeningTo
local select = select
local StartEventTimer = TheEye.Core.Helpers.Timers.StartEventTimer
local tostring = tostring
local updateRate = 0.5


--[[ #this#TEMPLATE#
{
    inputValues = { #LABEL#SpellID# #INT# }
}
]]


this.reevaluateEvents =
{
    SPELL_UPDATE_USABLE = true,
}
this.gameEvents =
{
    "UNIT_SPELLCAST_SUCCEEDED",
    "SPELL_UPDATE_USABLE",
}
this.customEvents =
{
    "SPELL_COOLDOWN_TIMER_END",
}


local function TimerStart(inputGroup, timerLength)
    if timerLength == initialTimerLength or timerLength == updateRate then
        StartEventTimer(timerLength, "SPELL_COOLDOWN_TIMER_END", inputGroup.inputValues)
    else
        InputGroupDurationTimerStart(inputGroup, timerLength, "SPELL_COOLDOWN_TIMER_END", inputGroup.inputValues)
    end
end

local function RemainingTimeCalculate(startTime, duration)
    local remainingTime = (startTime + duration) - GetTime()

    if remainingTime < 0 then
        remainingTime = 0
    end

    return remainingTime
end

local function CalculateCurrentValue(inputValues)
    local startTime, duration = GetSpellCooldown(inputValues[1])
    return RemainingTimeCalculate(startTime, duration), startTime
end

function this:InputGroupSetup(inputGroup)
    local gcdStartTime, gcdDuration = GetSpellCooldown(61304)
    inputGroup.currentValue, startTime = CalculateCurrentValue(inputGroup.inputValues)

    inputGroup.isGCD = true

    if startTime == gcdStartTime then
        inputGroup.currentValue = 0
    else
        TimerStart(inputGroup, inputGroup.currentValue)
    end
end

function this:GetKey(event, ...)
    local spellID

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit = ...
        if unit == "player" then
            spellID = select(3, ...)
        end
    else -- SPELL_COOLDOWN_TIMER_END
        local inputValues = select(2, ...)
        spellID = inputValues[1]
    end

    return tostring(spellID)
end

function this:Evaluate(inputGroup, event)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        TimerStart(inputGroup, initialTimerLength)
        inputGroup.isGCD = false
    else -- SPELL_COOLDOWN_TIMER_END, SPELL_UPDATE_USABLE
        local gcdStartTime, gcdDuration = GetSpellCooldown(61304)
        local gcdRemainingTime = RemainingTimeCalculate(gcdStartTime, gcdDuration)
        local remainingTime, startTime = CalculateCurrentValue(inputGroup.inputValues)

        if remainingTime > 0 and event ~= "SPELL_UPDATE_USABLE" then
            if remainingTime ~= gcdRemainingTime then
                TimerStart(inputGroup, updateRate)
            else
                TimerStart(inputGroup, remainingTime)
            end
        end

        if remainingTime == 0 or inputGroup.isGCD == false then
            if remainingTime == 0 or startTime == gcdStartTime then
                inputGroup.isGCD = true
            end

            inputGroup.currentValue = remainingTime
            return true, this.key
        end
    end
end