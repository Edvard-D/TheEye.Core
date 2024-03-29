-- @TODO Implement tracking of friendly units using beneficial and harmful AoE spells.
TheEye.Core.Evaluators.UNIT_COUNT_CLOSE_TO_UNIT_CHANGED = {}
local this = TheEye.Core.Evaluators.UNIT_COUNT_CLOSE_TO_UNIT_CHANGED

local bit = bit
local GetTime = GetTime
local InputGroupRegisterListeningTo = TheEye.Core.Managers.Evaluators.InputGroupRegisterListeningTo
local math = math
local meleeEventMaxElapsedTime = 5
local playerInitiatedMultiplier = 3
local reevaluateRate = 0.5
local spellEventMaxElapsedTime = 3
local StartEventTimer = TheEye.Core.Helpers.Timers.StartEventTimer
local table = table
local UnitCanAttack = UnitCanAttack
local UnitGUID = UnitGUID
local unpack = unpack


--[[ #this#TEMPLATE#
{
    inputValues =
    {
        #LABEL#Unit# #UNIT#
        #LABEL#Hostility Mask# #MASK#HOSTILITY#
    }
}
]]


this.reevaluateEvents =
{
    SPELL_DAMAGE = true,
    SWING_DAMAGE = true,
    UNIT_AFFECTING_COMBAT_CHANGED = true,
    UNIT_DESTROYED = true,
    UNIT_DIED = true,
    UNIT_DISSIPATES = true,
}
this.customEvents =
{
    "UNIT_COUNT_CLOSE_TO_UNIT_EVALUATE_TIMER_END",
}
local combatLogEvents =
{
    "SPELL_DAMAGE",
    "SWING_DAMAGE",
    "UNIT_DESTROYED",
    "UNIT_DIED",
    "UNIT_DISSIPATES",
}


function this:SetupListeningTo(inputGroup)
    for i = 1, #combatLogEvents do
        InputGroupRegisterListeningTo(inputGroup,
        {
            listeningToKey = "COMBAT_LOG",
            evaluator = this,
            inputValues = { combatLogEvents[i], "_", "_" }
        })
    end

    InputGroupRegisterListeningTo(inputGroup,
    {
        listeningToKey = "UNIT_AFFECTING_COMBAT_CHANGED",
        evaluator = this,
        inputValues = { "player", }
    })
end

local function TimerStart(inputGroup)
    StartEventTimer(reevaluateRate, "UNIT_COUNT_CLOSE_TO_UNIT_EVALUATE_TIMER_END", inputGroup.inputValues)
end

function this:InputGroupSetup(inputGroup)
    inputGroup.currentValue = 0
    inputGroup.groupedUnits =
    {
        guids = {},
    }
    inputGroup.meleeUnits =
    {
        guids = {},
    }
    inputGroup.events =
    {
        pending = {},
        current = { destGUIDs = {}, }
    }

    TimerStart(inputGroup)
end

function this:GetKey(event, duration, inputValues) -- only called on UNIT_COUNT_CLOSE_TO_UNIT_EVALUATE_TIMER_END
    return table.concat(inputValues)
end


-- Current/Pending Events
local function EventIsValid(inputGroup, eventData)
    local inputValueUnitGUID = UnitGUID(inputGroup.inputValues[1])
    local playerGUID = UnitGUID("player")

    if (eventData.event == "SWING_DAMAGE"
            and (eventData.sourceGUID == inputValueUnitGUID
                or eventData.destGUID == inputValueUnitGUID
                or eventData.destGUID == playerGUID) -- @TODO Create table that stores the GUIDs for each unitID
        or (eventData.event == "SPELL_DAMAGE"
            and bit.band(eventData.destFlags, inputGroup.inputValues[2]) > 0))
    then
        return true
    end
end

local function CurrentEventTryAddData(inputGroup, eventData)
    local currentEvent = inputGroup.events.current

    if EventIsValid(inputGroup, eventData) then
        if currentEvent.event == nil then
            currentEvent.sourceGUID = eventData.sourceGUID
            currentEvent.event = eventData.event
            currentEvent.timestamp = eventData.timestamp
        end
        table.insert(currentEvent.destGUIDs, eventData.destGUID)
    end
end

local function SpellEventHasValidMeleeUnit(inputGroup, event)
    local meleeUnits = inputGroup.meleeUnits
    local destGUIDs = event.destGUIDs

    for i = 1, #destGUIDs do
        if meleeUnits[destGUIDs[i]] ~= nil then
            return true
        end
    end

    return false
end

local function CurrentEventEvaluateForPending(inputGroup)
    local currentEvent = inputGroup.events.current
    local isValidEvent = false

    if currentEvent.event == "SWING_DAMAGE" then
        isValidEvent = true
    elseif #currentEvent.destGUIDs > 1 then -- SPELL_DAMAGE then
        isValidEvent = table.hasvalue(currentEvent.destGUIDs, UnitGUID(inputGroup.inputValues[1])) == true -- @TODO Create table that stores the GUIDs for each unitID
        
        if isValidEvent == false then
            isValidEvent = SpellEventHasValidMeleeUnit(inputGroup, currentEvent)
        end
    end
    
    if isValidEvent == true then
        currentEvent.wasInitiatorPlayer = currentEvent.sourceGUID == UnitGUID("player") -- @TODO Create table that stores the GUIDs for each unitID
        table.insert(inputGroup.events.pending, currentEvent)
    end
end


-- GroupedUnits
local function GroupedUnitEventWeightGet(event)
    local weightedValue = 1

    if event.wasInitiatorPlayer == true then
        weightedValue = weightedValue * playerInitiatedMultiplier
    end

    return weightedValue
end

local function GroupedUnitWeightGet(groupedUnit)
    local events = groupedUnit.events
    local weight = 0

    for i = 1, #events do
        weight = weight + GroupedUnitEventWeightGet(events[i])
    end

    return weight
end

local function GroupedUnitsHighestWeightUpdate(groupedUnits)
    local guids = groupedUnits.guids
    local highestWeight = 0

    for i = 1, #guids do
        local groupedUnit = groupedUnits[guids[i]]

        groupedUnit.weight = GroupedUnitWeightGet(groupedUnit)
        if groupedUnit.weight > highestWeight then
            highestWeight = groupedUnit.weight
        end
    end
    
    groupedUnits.highestWeight = highestWeight
end

local function GroupedUnitCountGetWeighted(inputGroup)
    local groupedUnits = inputGroup.groupedUnits
    local unitCount = 0

    if groupedUnits ~= nil then
        local guids = groupedUnits.guids
        local highestWeight = groupedUnits.highestWeight

        for i = 1, #guids do
            unitCount = unitCount + (groupedUnits[guids[i]].weight / highestWeight)
        end
    end

    return math.floor(unitCount + 0.5)
end


-- MeleeUnits
local function MeleeAttackingPlayerUnitCountGet(inputGroup)
    local meleeAttackingPlayerCount = 0
    local meleeUnits = inputGroup.meleeUnits
    local playerGUID = UnitGUID("player")

    if meleeUnits ~= nil then
        for unitGUID,unitData in pairs(meleeUnits) do
            local isAttackingPlayer = false

            if unitData.events ~= nil then
                for j = 1, #unitData.events do
                    local event = unitData.events[j]

                    if event.destGUIDs ~= nil and event.destGUIDs[1] == playerGUID then
                        isAttackingPlayer = true
                    end
                end

                if isAttackingPlayer == true then
                    meleeAttackingPlayerCount = meleeAttackingPlayerCount + 1
                end
            end
        end
    end

    return meleeAttackingPlayerCount
end


-- Units
local function UnitAddEventData(units, guid, eventData, eventMaxElapsedTime)
    if units[guid] == nil then
        units[guid] =
        {
            guid = guid,
            events = {},
        }
        table.insert(units.guids, guid)
    end

    eventData.eventMaxElapsedTime = eventMaxElapsedTime
    table.insert(units[guid].events, eventData)
end

local function UnitRemove(units, guid)
    if units ~= nil and units[guid] ~= nil then
        units[guid] = nil
        table.removevalue(units.guids, guid)
    end
end

local function EventsRemoveOld(events)
    if #events > 0 then
        local currentTime = GetTime()
        local oldestTimestamp = events[1].timestamp
        local eventMaxElapsedTime = events[1].eventMaxElapsedTime

        if currentTime - oldestTimestamp > eventMaxElapsedTime then
            for i = #events, 1, -1 do
                if currentTime - events[i].timestamp > eventMaxElapsedTime then
                    table.remove(events, i)
                end
            end
        end
    end
end

local function UnitsRemoveOldEvents(units)
    local guids = units.guids

    for i = #guids, 1, -1 do
        local guid = guids[i]
        local events = units[guid].events

        EventsRemoveOld(events)

        if #events == 0 then
            UnitRemove(units, guid)
        end
    end
end

local function UnitsUpdateWithPendingEvents(inputGroup)
    local pendingEvents = inputGroup.events.pending
    local inputValueUnitGUID = UnitGUID(inputGroup.inputValues[1])

    if #pendingEvents > 0 then
        local meleeUnits = inputGroup.meleeUnits
        local groupedUnits = inputGroup.groupedUnits

        for i = 1, #pendingEvents do
            local pendingEvent = pendingEvents[i]

            if pendingEvent.event == "SPELL_DAMAGE" then
                local destGUIDs = pendingEvent.destGUIDs

                for j = 1, #destGUIDs do
                    UnitAddEventData(groupedUnits, destGUIDs[j], pendingEvent, spellEventMaxElapsedTime)
                end
            else -- SWING_DAMAGE
                if pendingEvent.sourceGUID == inputValueUnitGUID then
                    UnitAddEventData(meleeUnits, pendingEvent.destGUIDs[1], pendingEvent, meleeEventMaxElapsedTime)
                else
                    UnitAddEventData(meleeUnits, pendingEvent.sourceGUID, pendingEvent, meleeEventMaxElapsedTime)
                end
            end
        end
    end
end

local function UnitsUpdate(inputGroup)
    UnitsUpdateWithPendingEvents(inputGroup)

    UnitsRemoveOldEvents(inputGroup.meleeUnits)
    UnitsRemoveOldEvents(inputGroup.groupedUnits)

    GroupedUnitsHighestWeightUpdate(inputGroup.groupedUnits)
end


function this:Evaluate(inputGroup, event, ...)
    local eventInputGroup = ...
    local unitCount

    if event == "UNIT_AFFECTING_COMBAT_CHANGED" then
        if eventInputGroup.currentValue == false then
            table.cleararray(inputGroup.unevaluatedEvents)
        end
    elseif event ~= "UNIT_COUNT_CLOSE_TO_UNIT_EVALUATE_TIMER_END" then -- combatLogEvents
        local eventData = eventInputGroup.eventData
        
        if event == "SPELL_DAMAGE" or event == "SWING_DAMAGE" then
            local currentEvent = inputGroup.events.current
            
            if currentEvent ~= nil and currentEvent.timestamp ~= eventData.timestamp then
                CurrentEventEvaluateForPending(inputGroup)
                inputGroup.events.current = { destGUIDs = {}, }
            end

            CurrentEventTryAddData(inputGroup, eventData)
        else -- UNIT_DESTROYED, UNIT_DIED, UNIT_DISSIPATES
            UnitRemove(inputGroup.meleeUnits, eventData.destGUID)
            UnitRemove(inputGroup.groupedUnits, eventData.destGUID)
        end
    else -- UNIT_COUNT_CLOSE_TO_UNIT_EVALUATE_TIMER_END
        UnitsUpdate(inputGroup)
        TimerStart(inputGroup)
        inputGroup.events.pending = {}
    end


    unitCount = GroupedUnitCountGetWeighted(inputGroup)
    if unitCount == 0 then
        unitCount = MeleeAttackingPlayerUnitCountGet(inputGroup)
    end


    if inputGroup.currentValue ~= unitCount then
        inputGroup.currentValue = unitCount
        return true, this.name
    end
end