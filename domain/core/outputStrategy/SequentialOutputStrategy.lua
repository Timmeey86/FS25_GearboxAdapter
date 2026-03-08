---Sequentially selects the gears in the vehicle.
---
---If the vehicle has less gears than the current number, the highest gear will be selected.
---If the vehicle has more gears then the player can input, then the highest gears will be unreachable.
---
---@class SequentialOutputStrategy
---@field vehicleGearboxInfo VehicleGearboxInfo|nil @Information about the current vehicle's gearbox.
---@field gearChangeImpl GearChangeInterface @The implementation to call for applying gear changes to the vehicle.
SequentialOutputStrategy = {}
local SequentialOutputStrategy_mt = Class(SequentialOutputStrategy, OutputTransformationStrategy)

---Constructor
---@param gearChangeImpl GearChangeInterface @The implementation to call for applying gear changes to the vehicle.
---@return OutputTransformationStrategy @The public interface of the class
function SequentialOutputStrategy.new(gearChangeImpl)
	local self = setmetatable({}, SequentialOutputStrategy_mt)
	self.vehicleGearboxInfo = nil
	self.gearChangeImpl = gearChangeImpl
	return self
end

---Registers a new vehicle gear/group layout to be processed from now on
---@param vehicleGearboxInfo VehicleGearboxInfo information about the vehicle's gearbox or nil if no vehicle
function SequentialOutputStrategy:setGearboxInfo(vehicleGearboxInfo)
	self.vehicleGearboxInfo = vehicleGearboxInfo
end

---Applies new gear selection data to the vehicle.
---@param gearSelectionData GearSelectionData @Data on the groups/gears to select in the vehicle.
function SequentialOutputStrategy:applyNewData(gearSelectionData)

	local outputGroup
	local outputGear

	if self.vehicleGearboxInfo and self.vehicleGearboxInfo.maxReverseGears == 0 and gearSelectionData.sequentialGear < 0 then
		-- The vehicle has no reverse gears, but rather requires the player to actively change direction.
		-- Ignore the reversing request.
		g_currentMission:showBlinkingWarning(g_i18n:getText("GA_WARNING_NO_REVERSE_GEARS", MOD_NAME), 2000)
		return
	end

	if self.vehicleGearboxInfo and self.vehicleGearboxInfo.maxGroups == 1 then
		-- Easy case: Just select the sequential gear number
		if gearSelectionData.sequentialGear == 0 then
			outputGroup = nil -- do not change group
		else
			outputGroup = gearSelectionData.sequentialGear > 0 and 1 or -1
		end
		outputGear = gearSelectionData.sequentialGear
	elseif gearSelectionData.sequentialGear == 0 then
		-- neutral gear
		outputGroup = nil -- do not change group
		outputGear = 0
	elseif gearSelectionData.sequentialGear > 0 then
		-- Calculate the effective group and gear
		outputGroup = (gearSelectionData.sequentialGear - 1) // self.vehicleGearboxInfo.maxForwardGears + 1
		outputGear = (gearSelectionData.sequentialGear - 1) % self.vehicleGearboxInfo.maxForwardGears + 1
	else
		-- reverse gear
		outputGroup = -1 -- assumption: Vehicles don't have more than one reverse gear group
		outputGear = gearSelectionData.sequentialGear
	end

	-- If the output gear is out of bounds, clamp it to the closest valid gear.
	outputGear = math.clamp(outputGear, -self.vehicleGearboxInfo.maxReverseGears, self.vehicleGearboxInfo.maxForwardGears)

	self.gearChangeImpl:changeGroupAndGear(outputGroup, outputGear)
end