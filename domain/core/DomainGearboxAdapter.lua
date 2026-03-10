---The domain core which converts generic gear inputs into a gear selection based on a selection of possible strategies
---@class DomainGearboxAdapter
---@field inputStrategies table<string, InputTransformationStrategy> @The registered input transformation strategies
---@field outputStrategies table<string, OutputTransformationStrategy> @The registered output transformation strategies
---@field activeInputStrategy InputTransformationStrategy @The currently active input transformation strategy
---@field activeOutputStrategy OutputTransformationStrategy @The currently active output transformation strategy
---@field gearChangeImpl GearChangeInterface @The implementation of the interface which changes gears in the FS vehicle.
---@field currentShifterInputData ShifterInputData @The current state of the player's controller inputs.
---@field vehicleGearboxInfo VehicleGearboxInfo|nil @Information about the current vehicle's gearbox or nil if no vehicle
---@field inputControllerInfo InputControllerInfo|nil @Information about the player's input controller(s) or nil if not set yet
---@field clutchEnabledFunc function @A function which checks whether the clutch is enabled in the settings.
DomainGearboxAdapter = {}
local DomainGearboxAdapter_mt = Class(DomainGearboxAdapter, GearboxAdapterInterface)

---Constructor.
---@param gearChangeImpl GearChangeInterface @The implementation of the interface which changes gears in the FS vehicle.
---@param clutchEnabledFunc function @A function which checks whether the clutch is enabled in the settings.
---@return GearboxAdapterInterface @The public interface of the class
function DomainGearboxAdapter.new(gearChangeImpl, clutchEnabledFunc)
	local self = setmetatable({}, DomainGearboxAdapter_mt)

	self.inputStrategies = {
		[GearboxAdapterInterface.INPUT_STRATEGY.EATON_FULLER_18] = EatonFuller18TransformationStrategy.new(),
	}
	self.outputStrategies = {
		[GearboxAdapterInterface.OUTPUT_STRATEGY.SEQUENTIAL] = SequentialOutputStrategy.new()
	}
	self.gearChangeImpl = gearChangeImpl
	self.clutchEnabledFunc = clutchEnabledFunc
	self.currentShifterInputData = ShifterInputData.new(0, 0, false)
	self.activeOutputStrategy = nil
	self.activeInputStrategy = nil
	self.vehicleGearboxInfo = nil
	self.inputControllerInfo = nil
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
	self.activeInputStrategy:setInputControllerInfo(self.inputControllerInfo)
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

---Tells the domain core what kind of input controller the player is using
---@param inputControllerInfo InputControllerInfo @information about the player's input controller(s)
function DomainGearboxAdapter:setInputControllerInfo(inputControllerInfo)
	if self.activeInputStrategy then
		self.activeInputStrategy:setInputControllerInfo(inputControllerInfo)
	end
	-- Reset input data
	self.currentShifterInputData = ShifterInputData.new(0, 0, false)
end

---Ask the domain core to process a change in the gear group input. Dependent on the transformation strategy, this may or may not result in this very gear group being selected in the vehicle.
---@param group number @The new gear group number
function DomainGearboxAdapter:setGearGroupInput(group)
	if not self.vehicleGearboxInfo or self.vehicleGearboxInfo.hasAutomaticShift then
		return
	end

	-- Handle special cases for when the clutch needs to be pressed, but wasn't pressed
	if self.activeInputStrategy then
		if self.clutchEnabledFunc() and self.vehicleGearboxInfo.needsClutchForGroups and not self.currentShifterInputData.clutchIsPressed then

			-- If the input strategy supports queueing, use that feature now
			if self.activeInputStrategy:supportsQueuingForGroups() then
				-- Remember the current shifter input. The next call on onInputChanged will apply that
				self.currentShifterInputData.currentGroup = group
				return
			else
				-- If it doesn't, the player can't change the group right now
				self.gearChangeImpl:showClutchWarningForGroupChange()
				return
			end
		end
	end

	-- All other cases: Change gear groups now
	self.currentShifterInputData.currentGroup = group
	self:onInputChanged()
end

---Ask the domain core to process a change in the gear input. Dependent on the transformation strategy, this may or may not result in this very gear being selected in the vehicle.
---@param gear number @The new gear number
function DomainGearboxAdapter:setGearInput(gear)
	if not self.vehicleGearboxInfo or self.vehicleGearboxInfo.hasAutomaticShift then
		return
	end
	-- Handle special cases for when the clutch needs to be pressed, but wasn't pressed
	if self.activeInputStrategy then
		if self.clutchEnabledFunc() and self.vehicleGearboxInfo.needsClutchForGears and not self.currentShifterInputData.clutchIsPressed then

			-- Always allow the neutral gear (you can remove the gear without pressing the clutch)
			-- This is specific for gears; there is no neutral group
			if gear == 0 then
				self.currentShifterInputData.currentGearSlot = 0
				self:onInputChanged()
				return
			end

			-- If the input strategy supports queueing, use that feature now
			if self.activeInputStrategy:supportsQueuingForGears() then
				self.currentShifterInputData.currentGearSlot = gear
				return
			else
				-- If it doesn't, the player can't change the group right now
				self.gearChangeImpl:showClutchWarningForGearChange()
				return
			end
		elseif not self.vehicleGearboxInfo.needsClutchForGears and gear == 0 then
			-- Do not shift into neutral for powershift transmissions
			return
		end
	end

	-- All other cases: Change gears now
	self.currentShifterInputData.currentGearSlot = gear
	self:onInputChanged()
end

---Call this function when the clutch state changes
---@param inputValue number @The clutch's input value (0..1, where 1 = pressed)
function DomainGearboxAdapter:setClutchState(inputValue)
	if not self.vehicleGearboxInfo or self.vehicleGearboxInfo.hasAutomaticShift then
		return
	end
	local clutchIsPressed = self.currentShifterInputData.clutchIsPressed

	-- Usually, a value of 0.5 would be used to switch between clutch pressed and released.
	-- We ask the clutch to be pressed 55% however, so if any game check is executed because of our gear or gear group changes,
	-- the clutch is still considered pressed by the game, even if we only catch it at 53% or something.
	if clutchIsPressed and inputValue < 0.55 then
		self.currentShifterInputData.clutchIsPressed = false
		self:onInputChanged()
	elseif not clutchIsPressed and inputValue >= 0.55 then
		self.currentShifterInputData.clutchIsPressed = true
		-- This applies pre-queued changes if necessary. It also tells the strategy that the clutch is pressed if it ever needs that info
		self:onInputChanged()
	end
	-- Else: The clutch was moved, but not enough to toggle the state => Ignore it.
end

---Calculates a new effective gear, transforms that to a real group and gear, and asks the gear change implementation to execute the change.
function DomainGearboxAdapter:onInputChanged()
	if not self.activeInputStrategy or not self.activeOutputStrategy then
		-- Ignore until the mod is set up correctly
		return
	end

	local gearSelectionHint = self.activeInputStrategy:calculateEffectiveGear(self.currentShifterInputData)

	-- If the vehicle has no reverse gears, but the player selected a reverse gear, ignore the request and show a warning instead
	if self.vehicleGearboxInfo and self.vehicleGearboxInfo.maxReverseGears == 0 and gearSelectionHint.direction < 0 then
		-- The vehicle has no reverse gears, but rather requires the player to actively change direction.
		-- Ignore the reversing request.
		self.gearChangeImpl:showManualDirectionChangeWarning()
		return
	end

	local gearCalculationResult = self.activeOutputStrategy:calculateGearSelection(gearSelectionHint)
	if gearCalculationResult then
		self.gearChangeImpl:applyChanges(gearCalculationResult)
	-- else: Nothing has changed effectively, e.g. when you use 10 inputs to control 4 gears, or whatever reason else
	end
end