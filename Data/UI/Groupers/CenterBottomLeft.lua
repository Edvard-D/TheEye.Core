local parentKey = "CENTER_BOTTOM"

TheEye.Core.Managers.UI.GrouperAdd(
{
    tags = { "CENTER_BOTTOM_LEFT", },
    Child =
    {
        parentKey = parentKey,
    },
    EnabledState =
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
                    eventEvaluatorKey = "UIOBJECT_COMPONENT_STATE_CHANGED",
                    inputValues = { --[[uiObjectKey]] parentKey, --[[componentName]] "VisibleState" },
                    value = 2,
                },
            },
        },
    },
    Frame =
    {
        Dimensions =
        {
            PointSettings =
            {
                point = "TOPRIGHT",
                relativePoint = "TOP",
                offsetX = -32.5,
                offsetY = -5,
            },
        },
    },
    Group =
    {
        childArranger = TheEye.Core.Helpers.ChildArrangers.Vertical,
        childPadding = 5,
        sortActionName = "SortAscending",
        sortValueComponentName = "PriorityRank",
    },
    VisibleState =
    {
        ValueHandler =
        {
            validKeys = { [0] = true },
        },
    },
})