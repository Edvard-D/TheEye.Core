local parentKey = "UIPARENT"

TheEyeAddon.UI.Objects:FormatData(
{
    tags = { "GROUP", "HUD", },
    Child =
    {
        parentKey = parentKey,
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
                    eventEvaluatorKey = "UIOBJECT_MODULE_SETTING_CHANGED",
                    inputValues = { --[[uiObjectKey]] "#SELF#UIOBJECT#KEY#" },
                    value = 2,
                },
                {
                    eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                    inputValues = { --[[uiObjectKey]] parentKey, --[[componentName]] "VisibleState" },
                    value = 4,
                },
            },
        },
    },
    Group =
    {
        DisplayData =
        {
            DimensionTemplate =
            {
                PointSettings =
                {
                    point = "TOP",
                    relativePoint = "CENTER",
                    offsetY = -75,
                }
            },
        },
        childArranger = TheEyeAddon.UI.ChildArrangers.Delegate,
    },
    VisibleState =
    {
        ValueHandler =
        {
            validKeys = { [30] = true },
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
                {
                    eventEvaluatorKey = "UNIT_IN_COMBAT_CHANGED",
                    inputValues = { --[[unit]] "player" },
                    value = 4,
                },
                {
                    eventEvaluatorKey = "UNIT_HEALTH_PERCENT_CHANGED",
                    inputValues = { --[[unit]] "player" },
                    comparisonValues =
                    {
                        value = 0,
                        type = "GreaterThan"
                    },
                    value = 8,
                },
                {
                    eventEvaluatorKey = "UNIT_HEALTH_PERCENT_CHANGED",
                    inputValues = { --[[unit]] "target" },
                    comparisonValues =
                    {
                        value = 0,
                        type = "GreaterThan"
                    },
                    value = 16,
                },
            },
        },
    },
}
)