local TEA = TheEyeAddon
TEA.UIObjects.Icon = {}

local GetItemInfo = GetItemInfo
local GetSpellTexture = GetSpellTexture
local setmetatable = setmetatable


local function GetIconTextureFileID(iconObjectType, iconObjectID)
	local fileID = nil

	if iconObjectType == TEA.UIObjects.IconObjectType.Spell then
		fileID = GetSpellTexture(iconObjectID)
		if fileID == nil then
			error("Could not find a spell with an ID of " ..
			tostring(iconObjectID) ..
			".")
			return
		end
	elseif iconObjectType == TEA.UIObjects.IconObjectType.Item then
		local _, _, _, _, _, _, _, _, _, fileID = GetItemInfo(iconObjectID)
		if fileID == nil then
			error("Could not find an item with an ID of " ..
			tostring(iconObjectID) ..
			".")
			return
		end
	else
		error("No IconObjectType exists with a value of " ..
		tostring(iconObjectType) ..
		". iconObjectID passed: " ..
		tostring(iconObjectID) ..
		".")
		return
	end

	return fileID
end


function TheEyeAddon.UIObjects.Icon:Create(
		parentFrame,
		width, height,
		point, relativePoint, offsetX, offsetY,
		iconObjectType, iconObjectID,
		isTextDisplay, text,
		isCooldownDisplay, isReversed)

	local instance = TEA.UIObjects.FrameFactory:Create(
			"Frame", parentFrame,
			width, height,
			point, relativePoint, offsetX, offsetY)

	local iconTextureFileID = GetIconTextureFileID(iconObjectType, iconObjectID)
	instance.texture = TEA.UIObjects.TextureFactory:Create(instance, "ARTWORK", iconTextureFileID)

	if isTextDisplay == true then
		instance.text = TEA.UIObjects.FontStringFactory:Create(instance, "OVERLAY", text)
	end

	if isCooldownDisplay == true then
		instance.cooldown = TEA.UIObjects.Cooldown:Create(instance, width, height, isReversed)
	end


	setmetatable(instance, TEA.UIObjects.Icon)
	self.__index = self

	return instance
end