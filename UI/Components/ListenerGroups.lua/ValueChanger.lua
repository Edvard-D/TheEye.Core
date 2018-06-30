local TheEyeAddon = TheEyeAddon
TheEyeAddon.UI.Objects.Components.ListenerGroups.ValueChanger = {}
local this = TheEyeAddon.UI.Objects.Components.ListenerGroups.ValueChanger


-- SETUP
--      instance
--      ValueHandler
--      OnEvaluate          function(...)
function this:Setup(
    instance,
    ValueHandler,
    OnEvaluate
)

    TheEyeAddon.UI.Objects.Components.ListenerGroups.Base:Setup(
        instance,
        TheEyeAddon.UI.Objects.Components.Listeners.ValueChanger.Setup,
        ValueHandler.Reset,
        ValueHandler.Reset,
        OnEvaluate
    )

    instance.ValueHandler = ValueHandler
end