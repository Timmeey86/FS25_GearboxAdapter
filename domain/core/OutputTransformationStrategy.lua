---An internal interface for transformation strategies
---@class OutputTransformationStrategy
OutputTransformationStrategy = {}

---Registers a new vehicle gear/group layout to be processed from now on
---@param vehicleGearboxInfo VehicleGearboxInfo|nil information about the vehicle's gearbox or nil if no vehicle
function OutputTransformationStrategy:setGearboxInfo(vehicleGearboxInfo)
	error("Method 'setGearboxInfo' not defined in implementing class")
end

---Applies new gear selection data to the vehicle.
---@param gearSelectionData GearSelectionData @Data on the groups/gears to select in the vehicle.
function OutputTransformationStrategy:applyNewData(gearSelectionData)
	error("Method 'applyNewData' not defined in implementing class")
end