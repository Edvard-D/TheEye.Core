local parentKey = "HUD_MODULE_PRIMARY"
local spellID = 8092

TheEyeAddon.UI.Objects:FormatData(
{
    tags = { "HUD", "ICON", "PRIMARY", "SPELL-8092", },
    CastStartAlert =
    {
        spellID = spellID,
    },
    Child =
    {
        parentKey = parentKey,
    },
    -- @TODO show charges
    EnabledState =
    {
        ValueHandler =
        {
            validKeys = { [2] = true, },
        },
        ListenerGroup =
        {
            Listeners =
            {
                {
                    eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                    inputValues = { --[[uiObjectKey]] parentKey, --[[componentName]] "VisibleState" },
                    value = 2,
                },
                {
                    eventEvaluatorKey = "PLAYER_TALENT_KNOWN_CHANGED",
                    inputValues = { --[[talentID]] 22314, },
                    value = 4,
                },
            },
        },
    },
    Icon =
    {
        DisplayData =
        {
            DimensionTemplate = TheEyeAddon.UI.DimensionTemplates.Icon.Large,
            iconObjectType = "SPELL",
            iconObjectID = spellID,
        },
    },
    PriorityRank =
    {
        ValueHandler =
        {
            validKeys = { [0] = 8, }
        },
    },
    ReadySoonAlert =
    {
        spellID = spellID
    },
    VisibleState =
    {
        ValueHandler =
        {
            validKeys = { [2] = true, [4] = true, [16] = true, [18] = true, [26] = true, },
        },
        ListenerGroup =
        {
            Listeners =
            {
                {
                    eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                    inputValues = { --[[uiObject]] "#SELF#UIOBJECT#KEY#", --[[componentName]] "CastStartAlert" },
                    value = 2,
                },
                {
                    eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                    inputValues = { --[[uiObject]] "#SELF#UIOBJECT#KEY#", --[[componentName]] "ReadySoonAlert" },
                    value = 4,
                },
                {
                    eventEvaluatorKey = "UNIT_SPELLCAST_ACTIVE_CHANGED",
                    inputValues = { --[[unit]] "player", --[[spellID]] spellID, },
                    value = 8,
                },
                {
                    eventEvaluatorKey = "PLAYER_SPELL_COOLDOWN_DURATION_CHANGED",
                    inputValues = { --[[spellID]] spellID },
                    comparisonValues =
                    {
                        value = 0,
                        type = "EqualTo"
                    },
                    value = 16,
                },
            },
        },
    },
}
)