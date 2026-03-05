---The domain core which converts generic gear inputs into a gear selection based on a selection of possible strategies
---@class DomainGearboxAdapter
---@field strategies table<string, InputTransformationStrategy> @The registered input transformation strategies
---@field activeStrategy InputTransformationStrategy @The currently active input transformation strategy
---@field currentInputGear number @The currently selected gear input
---@field currentInputGroup number @The currently selected gear group input
---@field inputEnabled boolean @True while input shall be processed. False while outside a vehicle, or within a CVT vehicle, for example.
---@field gearChangeImpl GearChangeInterface @The implementation of the interface which changes gears in the FS vehicle.
DomainGearboxAdapter = {}
local DomainGearboxAdapter_mt = Class(DomainGearboxAdapter, GearboxAdapterInterface)

---Constructor
---@param gearChangeImpl GearChangeInterface @The implementation of the interface which changes gears in the FS vehicle.
---@return GearboxAdapterInterface @The public interface of the class
function DomainGearboxAdapter.new(gearChangeImpl)
	local self = setmetatable({}, DomainGearboxAdapter_mt)
	self.strategies = {
		[GearboxAdapterInterface.STRATEGY.SEQUENTIAL] = SequentialTransformationStrategy.new(),
	}
	self.currentInputGroup = 1
	self.currentInputGear = 1
	self.inputEnabled = false
	self.gearChangeImpl = gearChangeImpl
	return self
end

---Sets the input transformation strategy to be used.
---@param strategy string the identifier of the strategy to be used.
function DomainGearboxAdapter:setTransformationStrategy(strategy)
	if self.strategies[strategy] == nil then
		error("Strategy " .. strategy .. " not found in registered strategies")
		return
	end
	self.activeStrategy = self.strategies[strategy]
end

---Tells the domain core how many gear groups and gears per gear group the vehicle has. Supply nil to both parameters when leaving a vehicle
---@param groupCount number|nil @The number of gear groups the vehicle has
---@param gearCount number|nil @The number of gears per gear group the vehicle has. If groupCount is nil, 0 or 1, this is the total number of gears.
function DomainGearboxAdapter:setCurrentGearLayout(groupCount, gearCount)
	if not self.activeStrategy then
		return
	end
	if gearCount ~= nil then
		local totalGearCount = gearCount
		if groupCount ~= nil and groupCount > 1 then
			totalGearCount = groupCount * gearCount
		end
		Logging.info("Setting vehicle group count %s and gear count %s", groupCount, gearCount)
		self.activeStrategy:changeVehicle(groupCount or 1, gearCount, totalGearCount)
		self.inputEnabled = true
	else
		self.inputEnabled = false
	end
end

---Tells the domain core how many gears and groups the player can select
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxGears number @The number of gears per gear group the player can select with their controller.
function DomainGearboxAdapter:setInputLimits(maxGroups, maxGears)
	if not self.activeStrategy then
		return
	end
	self.activeStrategy:setInputLimits(maxGroups, maxGears, maxGroups * maxGears)
end


---Tells the domain core to process a change in the gear group input. Dependent on the transformation strategy, this may or may not result in this very gear group being selected in the vehicle.
---@param group number @The new gear group number
function DomainGearboxAdapter:setGearGroupInput(group)
	if not self.activeStrategy or not self.inputEnabled then
		Logging.info("Skipping gear group since no strategy or input disabled")
		return
	end
	self.currentInputGroup = group or 1
	if self.currentInputGroup and self.currentInputGear then
		local vehicleGroup, vehicleGear = self.activeStrategy:transformGearInput(self.currentInputGroup, self.currentInputGear)
		Logging.info("Switching to gear group %s and gear %s", vehicleGroup, vehicleGear)
		self.gearChangeImpl:changeGroupAndGear(vehicleGroup, vehicleGear)
	end
end

---Tells the domain core to process a change in the gear input. Dependent on the transformation strategy, this may or may not result in this very gear being selected in the vehicle.
---@param gear number @The new gear number
function DomainGearboxAdapter:setGearInput(gear)
	if not self.activeStrategy or not self.inputEnabled then
		Logging.info("Skipping gear input since no strategy or input disabled")
		return
	end
	self.currentInputGear = gear or 1
	if self.currentInputGroup and self.currentInputGear then
		local vehicleGroup, vehicleGear = self.activeStrategy:transformGearInput(self.currentInputGroup, self.currentInputGear)
		Logging.info("Switching to gear group %s and gear %s", vehicleGroup, vehicleGear)
		self.gearChangeImpl:changeGroupAndGear(vehicleGroup, vehicleGear)
	end
end