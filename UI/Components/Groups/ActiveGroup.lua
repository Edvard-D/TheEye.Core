TheEye.Core.UI.Components.ActiveGroup = {}
local this = TheEye.Core.UI.Components.ActiveGroup
local inherited = TheEye.Core.UI.Components.PriorityGroup

local GetPropertiesOfType = TheEye.Core.Managers.Icons.GetPropertiesOfType


--[[ #this#TEMPLATE#
{
    #inherited#TEMPLATE#
}
]]


--[[ SETUP
    instance
]]
function this.Setup(
    instance
)
    inherited.Setup(
        instance
    )

    local icons = instance.Icons
    for i = 1, #icons do
        local baseModifierKeyValue = 0
        local icon = icons[i]
        local iconUIObject = icon.UIObject
        local validKeys = iconUIObject.VisibleState.ValueHandler.validKeys
        local value = 1

        local CATEGORY = GetPropertiesOfType(icon, "CATEGORY")
        local OBJECT_ID = GetPropertiesOfType(icon, "OBJECT_ID")
        local POWER_REQUIRED = GetPropertiesOfType(icon, "POWER_REQUIRED")


        -- BUFF
        if (CATEGORY.value == "BUFF" and CATEGORY.subvalue == "POWER")
            or CATEGORY.value == "DEFENSIVE"
            or CATEGORY.value == "HEAL"
            then
            value = value * 2
            baseModifierKeyValue = baseModifierKeyValue + value

            table.insert(iconUIObject.VisibleState.ListenerGroup.Listeners,
                {
                    eventEvaluatorKey = "UNIT_AURA_ACTIVE_CHANGED",
                    inputValues = { --[[sourceUnit]] "_", --[[destUnit]] "player", --[[spellID]] OBJECT_ID.value, },
                    value = value,
                }
            )

            if POWER_REQUIRED == nil then
                iconUIObject["AuraDuration"] = { spellID = OBJECT_ID.value, }
            else
                iconUIObject["LowPowerAlert"] =
                {
                    powerID = POWER_REQUIRED.value,
                    spellID = OBJECT_ID.value,
                }
            end
        end

        -- SUMMON
        if CATEGORY.value == "DAMAGE" and CATEGORY.subvalue == "SUMMON" then
            value = value * 2
            baseModifierKeyValue = baseModifierKeyValue + value

            table.insert(iconUIObject.VisibleState.ListenerGroup.Listeners,
                {
                    eventEvaluatorKey = "UNIT_SUMMONED_ACTIVE_ELAPSED_TIME_CHANGED",
                    inputValues = { --[[sourceUnit]] "player", --[[spellID]] OBJECT_ID.value, },
                    comparisonValues =
                    {
                        floor = 0.001, -- Represents value of 0 but must be greater than 0
                        ceiling = CATEGORY.duration,
                        type = "Between"
                    },
                    value = value,
                }
            )
        end

        -- TOTEM
        if CATEGORY.value == "DAMAGE" and CATEGORY.subvalue == "TOTEM" then
            value = value * 2
            baseModifierKeyValue = baseModifierKeyValue + value

            local spellName = GetSpellInfo(OBJECT_ID.value)
            table.insert(iconUIObject.VisibleState.ListenerGroup.Listeners,
                {
                    eventEvaluatorKey = "PLAYER_TOTEM_ACTIVE_CHANGED",
                    inputValues = { --[[totemName]] spellName, },
                    value = value,
                }
            )
        end


        -- ValidKeys
        validKeys[baseModifierKeyValue] = true
    end
end