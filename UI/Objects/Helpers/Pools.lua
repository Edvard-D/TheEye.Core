local TheEyeAddon = TheEyeAddon
TheEyeAddon.UI.Pools = {}

local ipairs = ipairs
local table = table


function TheEyeAddon.UI.Pools.Release(frame)
	frame:Hide()
	frame:SetParent(nil)
	frame.isClaimed = false
	frame.UIObject = nil
end

function TheEyeAddon.UI.Pools:Claim(uiObject, frameType, template, dimensionTemplate)
	local instance = nil
	for i,frame in ipairs(self.Instances) do
		if frame.isClaimed == false then
			instance = frame
			break
		end
	end
	
	if instance ~= nil then
		instance:SetParent(UIParent)
		instance.UIObject = uiObject
		TheEyeAddon.UI.Factories.Frame.SetDimensions(instance, UIParent, dimensionTemplate)
	else
		instance = TheEyeAddon.UI.Factories.Frame:Create(uiObject, "Frame", nil, dimensionTemplate)
		table.insert(self.Instances, instance)
	end

	instance.isClaimed = true
	instance:Show()

	return instance
end

function TheEyeAddon.UI.Pools:Create()
	local instance = { Claim = TheEyeAddon.UI.Pools.Claim, Instances = {} }
    table.insert(TheEyeAddon.UI.Pools, instance)
    return instance
end