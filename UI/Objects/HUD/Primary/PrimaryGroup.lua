TheEyeAddon.UI.Objects:FormatData(
{
    tags = { "HUD", "MODULE", "PRIMARY" },
    Children =
    {
        childTags = { --[[tags]] "HUD", "ICON", "PRIMARY" },
        GroupArranger = TheEyeAddon.UI.Objects.GroupArrangers.TopToBottom,
        sortActionName = "SortDescending",
        sortValueComponentName = "PriorityRank",
    },
    DisplayData =
    {
        factory = TheEyeAddon.UI.Factories.Group,
        DimensionTemplate =
        {
            PointSettings =
            {
                point = "TOP",
                relativePoint = "CENTER",
            },
        },
    },
    EnabledState =
    {
        ValueHandler =
        {
            validKeys = { [6] = true },
        },
        ListenerGroup =
        {
            Listeners =
            {
                {
                    eventEvaluatorKey = "UIOBJECT_MODULE_ENABLED_CHANGED",
                    inputValues = { --[[uiObjectKey]] "HUD_MODULE_PRIMARY" }, -- @TODO have Setup auto populate fields with some special character, like "#thisKey"
                    value = 2,
                },
                {
                    eventEvaluatorKey = "UIOBJECT_VISIBLE_CHANGED",
                    inputValues = { --[[uiObjectKey]] "UIPARENT" },
                    value = 4,
                },
            },
        },
    },
    VisibleState =
    {
        ValueHandler =
        {
            validKeys = { [2] = true },
        },
        ListenerGroup =
        {
            Listeners =
            {
                {
                    eventEvaluatorKey = "UNIT_CAN_ATTACK_UNIT_CHANGED",
                    inputValues = { --[[attackerUnit]] "player", --[[attackedUnit]] "target" },
                    value = 2,
                },
            },
        },
    },
}
)