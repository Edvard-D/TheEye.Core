local parentKey = "HUD_MODULE_ACTIVE"
local spellID = 34433

TheEyeAddon.UI.Objects:FormatData(
{
    tags = { "HUD", "ICON", "ACTIVE", "SPELL-34433", },
    DisplayData =
    {
        factory = TheEyeAddon.UI.Factories.Icon,
        DimensionTemplate = TheEyeAddon.UI.DimensionTemplates.Icon.Medium,
        iconObjectType = "SPELL",
        iconObjectID = spellID,
    },
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
                    eventEvaluatorKey = "UIOBJECT_VISIBLE_CHANGED",
                    inputValues = { --[[uiObjectKey]] parentKey, },
                    value = 2,
                },
                {
                    eventEvaluatorKey = "PLAYER_TALENT_KNOWN_CHANGED",
                    inputValues = { --[[talentID]] 21719, },
                    value = 4,
                },
            },
        },
    },
    Parent =
    {
        key = parentKey,
    },
    PriorityRank =
    {
        isDynamic = false,
        ValueHandler =
        {
            defaultValue = 3,
        },
    },
    VisibleState =
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
                    eventEvaluatorKey = "PLAYER_TOTEM_ACTIVE_CHANGED",
                    inputValues = { --[[totemName]] "Shadowfiend", },
                    value = 2,
                },
            },
        },
    },
}
)