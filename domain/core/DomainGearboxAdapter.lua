---The domain core which converts generic gear inputs into a gear selection based on a selection of possible strategies
---@class DomainGearboxAdapter
---@field inputStrategies table<string, InputTransformationStrategy> @The registered input transformation strategies
---@field outputStrategies table<string, OutputTransformationStrategy> @The registered output transformation strategies
---@field activeInputStrategy InputTransformationStrategy @The currently active input transformation strategy
---@field activeOutputStrategy OutputTransformationStrategy @The currently active output transformation strategy
---@field currentInputGear number @The currently selected gear input
---@field currentInputGroup number @The currently selected gear group input
---@field inputEnabled boolean @True while input shall be processed. False while outside a vehicle, or within a CVT vehicle, for example.
---@field gearChangeImpl GearChangeInterface @The implementation of the interface which changes gears in the FS vehicle.
---@field clutchIsPressed boolean @True while the clutch is pressed.
---@field lastVehicleGroupCount number|nil @The group count of the last known vehicle
---@field lastVehicleForwardGearCount number|nil @The forward gear count of the last known vehicle
---@field lastVehicleReverseGearCount number|nil @The reverse gear count of the last known vehicle
---@field lastInputMaxGroups number|nil @The max groups of the last known input limits
---@field lastInputMaxGears number|nil @The max gears of the last known input limits
DomainGearboxAdapter = {}
local DomainGearboxAdapter_mt = Class(DomainGearboxAdapter, GearboxAdapterInterface)

---Constructor. 
---@param gearChangeImpl GearChangeInterface @The implementation of the interface which changes gears in the FS vehicle.
---@param clutchEnabledFunc function @A function which checks whether the clutch is enabled in the settings.
---@return GearboxAdapterInterface @The public interface of the class
function DomainGearboxAdapter.new(gearChangeImpl, clutchEnabledFunc)
	local self = setmetatable({}, DomainGearboxAdapter_mt)

	local forwardToOutputStrategyFunc = function(gearSelectionData) self.activeOutputStrategy:applyNewData(gearSelectionData) end

	self.inputStrategies = {
		[GearboxAdapterInterface.INPUT_STRATEGY.EATON_FULLER_18] = EatonFuller18TransformationStrategy.new(clutchEnabledFunc, forwardToOutputStrategyFunc),
	}
	self.outputStrategies = {
		[GearboxAdapterInterface.OUTPUT_STRATEGY.SEQUENTIAL] = SequentialOutputStrategy.new(gearChangeImpl)
	}
	self.currentInputGroup = 1
	self.currentInputGear = 1
	self.inputEnabled = false
	self.clutchIsPressed = false
	self.activeOutputStrategy = nil
	self.activeInputStrategy = nil
	self.lastVehicleGroupCount = nil
	self.lastVehicleForwardGearCount = nil
	self.lastVehicleReverseGearCount = nil
	self.lastInputMaxGroups = nil
	self.lastInputMaxGears = nil
	return self
end

---Sets the input transformation strategy to be used.
---@param strategy string the identifier of the strategy to be used.
function DomainGearboxAdapter:setInputTransformationStrategy(strategy)
	if self.inputStrategies[strategy] == nil then
		error("Strategy " .. strategy .. " not found in registered strategies")
		return
	end
	self.activeInputStrategy = self.inputStrategies[strategy]
	-- Forward the current input limits to the strategy
	self:setInputLimits(self.lastInputMaxGroups, self.lastInputMaxGears)
end

---Sets the output transformation strategy to be used.
---@param strategy string the identifier of the strategy to be used.
function DomainGearboxAdapter:setOutputTransformationStrategy(strategy)
	if self.outputStrategies[strategy] == nil then
		error("Strategy " .. strategy .. " not found in registered strategies")
		return
	end
	self.activeOutputStrategy = self.outputStrategies[strategy]
	-- Forward the current vehicle's data to the output strategy
	self:setCurrentGearLayout(self.lastVehicleGroupCount, self.lastVehicleForwardGearCount, self.lastVehicleReverseGearCount)
end

---Tells the domain core how many gear groups and gears per gear group the vehicle has. Supply nil to both parameters when leaving a vehicle
---@param groupCount number|nil @The number of gear groups the vehicle has
---@param forwardGearCount number|nil @The number of gears per gear group the vehicle has. If groupCount is nil, 0 or 1, this is the total number of gears.
---@param reverseGearCount number|nil @The number of reverse gears the vehicle has.
function DomainGearboxAdapter:setCurrentGearLayout(groupCount, forwardGearCount, reverseGearCount)
	self.lastVehicleGroupCount = groupCount
	self.lastVehicleForwardGearCount = forwardGearCount
	self.lastVehicleReverseGearCount = reverseGearCount

	if not self.activeInputStrategy then
		return
	end
	if forwardGearCount ~= nil then
		local totalGearCount = forwardGearCount
		if groupCount ~= nil and groupCount > 1 then
			totalGearCount = groupCount * forwardGearCount
		end
		Logging.info("Setting to %s groups, %s forward gears per group and %s reverse gears", groupCount, forwardGearCount, reverseGearCount or 0)
		self.activeOutputStrategy:changeVehicle(groupCount or 1, forwardGearCount, reverseGearCount or 0, totalGearCount)
		self.inputEnabled = true
	else
		self.inputEnabled = false
	end
end

---Tells the domain core how many gears and groups the player can select
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxGears number @The number of gears per gear group the player can select with their controller.
function DomainGearboxAdapter:setInputLimits(maxGroups, maxGears)
	self.lastInputMaxGroups = maxGroups
	self.lastInputMaxGears = maxGears

	if not self.activeInputStrategy then
		return
	end
	self.activeInputStrategy:setInputLimits(maxGroups, maxGears)
end


---Tells the domain core to process a change in the gear group input. Dependent on the transformation strategy, this may or may not result in this very gear group being selected in the vehicle.
---@param group number @The new gear group number
function DomainGearboxAdapter:setGearGroupInput(group)
	if not self.activeInputStrategy or not self.inputEnabled then
		Logging.info("Skipping gear group since no strategy or input disabled")
		return
	end
	self.currentInputGroup = group or 1
	if self.currentInputGroup and self.currentInputGear then
		self.activeInputStrategy:changeGearGroup(self.currentInputGroup)
	end
end

---Tells the domain core to process a change in the gear input. Dependent on the transformation strategy, this may or may not result in this very gear being selected in the vehicle.
---@param gear number @The new gear number
function DomainGearboxAdapter:setGearInput(gear)
	if not self.activeInputStrategy or not self.inputEnabled then
		Logging.info("Skipping gear input since no strategy or input disabled")
		return
	end
	self.currentInputGear = gear or 1
	self.activeInputStrategy:changeGear(self.currentInputGear)
end

---Call this function when the clutch state changes
---@param inputValue number @The clutch's input value (0..1, where 1 = pressed)
function DomainGearboxAdapter:setClutchState(inputValue)
	if self.clutchIsPressed and inputValue < 0.5 then
		self.clutchIsPressed = false
		self.activeInputStrategy:setClutchPressed(false)
	elseif not self.clutchIsPressed and inputValue >= 0.5 then
		self.clutchIsPressed = true
		self.activeInputStrategy:setClutchPressed(true)
	end
end