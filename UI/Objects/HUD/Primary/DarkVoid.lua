local parentKey = "HUD_MODULE_PRIMARY"
local spellID = 263346

TheEyeAddon.Managers.UI:FormatData(
{
    tags = { "HUD", "ICON", "PRIMARY", "SPELL-263346", },
    CastSoonAlert =
    {
        spellID = spellID
    },
    CastStartAlert =
    {
        spellID = spellID,
    },
    Child =
    {
        parentKey = parentKey,
    },
    EnabledState =
    {
        ValueHandler =
        {
            validKeys = { [6] = true, },
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
                    inputValues = { --[[talentID]] 23127, },
                    value = 4,
                },
            },
        },
    },
    Frame =
    {
        Dimensions = TheEyeAddon.Values.DimensionTemplates.Icon.Large,
    },
    Icon =
    {
        iconObjectType = "SPELL",
        iconObjectID = spellID,
    },
    PriorityRank =
    {
        ValueHandler =
        {
            validKeys =
            {
                [0] = 6,
                [2] = 10,
            },
        },
        ListenerGroup =
        {
            Listeners =
            {
                {
                    eventEvaluatorKey = "UNIT_COUNT_CLOSE_TO_UNIT_CHANGED",
                    inputValues = { --[[unit]] "target", --[[hostilityMask]] COMBATLOG_OBJECT_REACTION_HOSTILE, },
                    comparisonValues =
                    {
                        value = 3,
                        type = "GreaterThanEqualTo"
                    },
                    value = 2,
                },
            },
        },
    },
    VisibleState =
    {
        ValueHandler =
        {
            validKeys =
            {
                [2] = true, [4] = true, [6] = true, [16] = true, [18] = true, [26] = true, [34] = true,
                [42] = true,
            },
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
                    inputValues = { --[[uiObject]] "#SELF#UIOBJECT#KEY#", --[[componentName]] "CastSoonAlert" },
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
                        type = "EqualTo",
                    },
                    value = 16,
                },
                {
                    eventEvaluatorKey = "UNIT_AURA_ACTIVE_CHANGED",
                    inputValues = { --[[sourceUnit]] "player", --[[destUnit]] "player", --[[spellID]] 194249, },
                    value = 32,
                },
            },
        },
    },
}
)