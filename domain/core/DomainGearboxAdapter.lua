---The domain core which converts generic gear inputs into a gear selection based on a selection of possible strategies
---@class DomainGearboxAdapter
---@field inputStrategies table<string, InputTransformationStrategy> @The registered input transformation strategies
---@field outputStrategies table<string, OutputTransformationStrategy> @The registered output transformation strategies
---@field activeInputStrategy InputTransformationStrategy @The currently active input transformation strategy
---@field activeOutputStrategy OutputTransformationStrategy @The currently active output transformation strategy
---@field currentInputGear number @The currently selected gear input
---@field currentInputGroup number @The currently selected gear group input
---@field gearChangeImpl GearChangeInterface @The implementation of the interface which changes gears in the FS vehicle.
---@field clutchIsPressed boolean @True while the clutch is pressed.
---@field vehicleGearboxInfo VehicleGearboxInfo|nil @Information about the current vehicle's gearbox or nil if no vehicle
DomainGearboxAdapter = {}
local DomainGearboxAdapter_mt = Class(DomainGearboxAdapter, GearboxAdapterInterface)

---Constructor. 
---@param gearChangeImpl GearChangeInterface @The implementation of the interface which changes gears in the FS vehicle.
---@param clutchEnabledFunc function @A function which checks whether the clutch is enabled in the settings.
---@return GearboxAdapterInterface @The public interface of the class
function DomainGearboxAdapter.new(gearChangeImpl, clutchEnabledFunc)
	local self = setmetatable({}, DomainGearboxAdapter_mt)

	local forwardToOutputStrategyFunc = function(gearSelectionData)
		self.activeOutputStrategy:applyNewData(gearSelectionData)
	end

	self.inputStrategies = {
		[GearboxAdapterInterface.INPUT_STRATEGY.EATON_FULLER_18] = EatonFuller18TransformationStrategy.new(clutchEnabledFunc, forwardToOutputStrategyFunc),
	}
	self.outputStrategies = {
		[GearboxAdapterInterface.OUTPUT_STRATEGY.SEQUENTIAL] = SequentialOutputStrategy.new(gearChangeImpl)
	}
	self.currentInputGroup = 1
	self.currentInputGear = 1
	self.clutchIsPressed = false
	self.activeOutputStrategy = nil
	self.activeInputStrategy = nil
	self.vehicleGearboxInfo = nil
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
	self.activeInputStrategy:setGearboxInfo(self.vehicleGearboxInfo)
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
	self.activeOutputStrategy:setGearboxInfo(self.vehicleGearboxInfo)
	-- Forward the current vehicle's data to the output strategy
	self:setGearboxInfo(self.vehicleGearboxInfo)
end

---Forwards information about the current vehicle to the domain core
---@param vehicleGearboxInfo VehicleGearboxInfo|nil information about the vehicle's gearbox or nil if no vehicle
function DomainGearboxAdapter:setGearboxInfo(vehicleGearboxInfo)
	self.vehicleGearboxInfo = vehicleGearboxInfo

	if self.activeInputStrategy then
		self.activeInputStrategy:setGearboxInfo(vehicleGearboxInfo)
	end
	if self.activeOutputStrategy then
		self.activeOutputStrategy:setGearboxInfo(vehicleGearboxInfo)
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
	if not self.activeInputStrategy then
		Logging.info("Skipping gear group since no strategy")
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
	if not self.activeInputStrategy then
		Logging.info("Skipping gear input since no strategy")
		return
	end
	self.currentInputGear = gear or 1
	self.activeInputStrategy:changeGear(self.currentInputGear)
end

---Call this function when the clutch state changes
---@param inputValue number @The clutch's input value (0..1, where 1 = pressed)
function DomainGearboxAdapter:setClutchState(inputValue)
	-- Usually, a value of 0.5 would be used to switch between clutch pressed and released.
	-- We ask the clutch to be pressed 60% however, so if any game check is executed because of our gear or gear group changes,
	-- the clutch is still considered pressed by the game, even if we only catch it at 58% or something.
	if self.clutchIsPressed and inputValue < 0.6 then
		self.clutchIsPressed = false
		self.activeInputStrategy:setClutchPressed(false)
	elseif not self.clutchIsPressed and inputValue >= 0.6 then
		self.clutchIsPressed = true
		self.activeInputStrategy:setClutchPressed(true)
	end
end