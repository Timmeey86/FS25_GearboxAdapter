dofile("src/domain/data/GearCalculationResult.lua")
dofile("src/domain/data/GearSelectionHint.lua")
dofile("src/domain/data/InputControllerInfo.lua")
dofile("src/domain/data/ShifterInputData.lua")
dofile("src/domain/data/VehicleGearboxInfo.lua")
dofile("src/domain/incoming/GearboxAdapterInterface.lua")
dofile("src/domain/core/InputTransformationStrategy.lua")
dofile("src/domain/core/inputStrategy/EatonFuller18InputStrategy.lua")
dofile("src/domain/core/inputStrategy/EatonFuller13InputStrategy.lua")
dofile("src/domain/core/inputStrategy/EatonFuller10InputStrategy.lua")
dofile("src/domain/core/inputStrategy/Scania12InputStrategy.lua")
dofile("src/domain/core/inputStrategy/Volvo12InputStrategy.lua")
dofile("src/domain/core/inputStrategy/ZF12InputStrategy.lua")
dofile("src/domain/core/inputStrategy/ZF16InputStrategy.lua")
dofile("src/domain/core/inputStrategy/GearsAndGroupsInputStrategy.lua")
dofile("src/domain/core/OutputTransformationStrategy.lua")
dofile("src/domain/core/outputStrategy/SequentialOutputStrategy.lua")
dofile("src/domain/core/outputStrategy/GearsAndGroupsOutputStrategy.lua")
dofile("src/domain/core/DomainGearboxAdapter.lua")

local mockGearChangeImpl = {
  applyChanges = function(gearCalculationResult) end,
  showClutchWarningForGroupChange = function() end,
  showClutchWarningForGearChange = function() end,
  showManualDirectionChangeWarning = function() end
}

local mockClutchIsEnabled = true
local mockClutchEnabledFunc = function() return mockClutchIsEnabled end

local gearboxAdapter = DomainGearboxAdapter.new(mockGearChangeImpl, mockClutchEnabledFunc)

---Defines unit tests for the DomainGearboxAdapter.
---Most of these tests are grey-/whitebox tests due to the lack of a mocking framework
describe("DomainGearboxAdapter", function()

	before_each(function()
		-- Reset the gearbox adapter before each test
		gearboxAdapter = DomainGearboxAdapter.new(mockGearChangeImpl, mockClutchEnabledFunc)
	end)

	it("should call setters when changing the active input strategy", function()
		-- GIVEN
		local actualGearboxInfo = nil
		local actualControllerInfo = nil
		local mockInputStrategy = {
			setGearboxInfo = function(self, gearboxInfo) actualGearboxInfo = gearboxInfo end,
			setInputControllerInfo = function(self, controllerInfo) actualControllerInfo = controllerInfo end
		}
		local expectedGearboxInfo = VehicleGearboxInfo.new(false, false, false, 3, 6, 1)
		local expectedControllerInfo = InputControllerInfo.new(2, 3)
		gearboxAdapter:setGearboxInfo(expectedGearboxInfo)
		gearboxAdapter:setInputControllerInfo(expectedControllerInfo)

		-- WHEN
		gearboxAdapter.inputStrategies["mock"] = mockInputStrategy
		gearboxAdapter:setInputStrategy("mock")

		-- THEN
		assert.are.equals(expectedGearboxInfo, actualGearboxInfo)
		assert.are.equals(expectedControllerInfo, actualControllerInfo)
		assert.are.equals(gearboxAdapter.activeInputStrategy, mockInputStrategy)
	end)

	it("should error on unknown input strategies", function()
		-- GIVEN

		-- WHEN / THEN
		assert.has_error(function() gearboxAdapter:setInputStrategy("does not exist") end)
	end)

	it("should error on unknown output strategies", function()
		-- GIVEN

		-- WHEN / THEN
		assert.has_error(function() gearboxAdapter:setOutputStrategy("does not exist") end)
	end)

	it("should allow switching output strategies", function()
		-- GIVEN
		local mockOutputStrategy = {}
		gearboxAdapter.outputStrategies["mock"] = mockOutputStrategy

		-- WHEN
		gearboxAdapter:setOutputStrategy("mock")

		-- THEN
		assert.are.equals(gearboxAdapter.activeOutputStrategy, mockOutputStrategy)
	end)

	it("should forward gearbox information", function()
		-- GIVEN
		local actualGearboxInfo = nil
		local mockInputStrategy = {
			setGearboxInfo = function(self, gearboxInfo) actualGearboxInfo = gearboxInfo end,
			setInputControllerInfo = function() end
		}
		local expectedGearboxInfo = VehicleGearboxInfo.new(false, false, false, 3, 6, 1)
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(expectedGearboxInfo)

		-- THEN
		assert.are.equals(expectedGearboxInfo, actualGearboxInfo)
	end)

	it("should forward input controller information", function()
		-- GIVEN
		local actualControllerInfo = nil
		local mockInputStrategy = {
			setGearboxInfo = function() end,
			setInputControllerInfo = function(self, controllerInfo) actualControllerInfo = controllerInfo end
		}
		local expectedControllerInfo = InputControllerInfo.new(2, 3)
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		-- WHEN
		gearboxAdapter:setInputControllerInfo(expectedControllerInfo)

		-- THEN
		assert.are.equals(expectedControllerInfo, actualControllerInfo)
	end)

	it("should ignore group and gear changes for CVT vehicles", function()
		-- GIVEN
		local cvtGearboxInfo = VehicleGearboxInfo.new(true, false, false, 0, 0, 0)
		local wasCalled = false
		local dummyGearChangeImpl = {
			applyChanges = function(gearCalculationResult) wasCalled = true end,
			showClutchWarningForGroupChange = function() wasCalled = true end,
			showClutchWarningForGearChange = function() wasCalled = true end,
			showManualDirectionChangeWarning = function() wasCalled = true end
		}
		gearboxAdapter.gearChangeImpl = dummyGearChangeImpl

		-- WHEN
		gearboxAdapter:setGearboxInfo(cvtGearboxInfo)
		gearboxAdapter:setGearGroupInput(1)
		gearboxAdapter:setGearInput(1)

		-- THEN
		assert.is_false(wasCalled)
	end)

	it("should trigger a visual warning when the clutch needs to be pressed, but isn't", function()
		-- GIVEN
		mockClutchIsEnabled = true
		local manualClutchGearboxInfo = VehicleGearboxInfo.new(false, true, true, 3, 6, 1)
		local wasGroupWarningCalled = false
		local wasGearWarningCalled = false
		local dummyGearChangeImpl = {
			applyChanges = function() end,
			showClutchWarningForGroupChange = function() wasGroupWarningCalled = true end,
			showClutchWarningForGearChange = function() wasGearWarningCalled = true end,
			showManualDirectionChangeWarning = function() end
		}
		gearboxAdapter.gearChangeImpl = dummyGearChangeImpl
		-- Simulate an input strategy which doesn't support Queueing, so without clutch presses, nothing can be changed
		local mockInputStrategy = {
			supportsQueueingForGears = function() return false end,
			supportsQueueingForGroups = function() return false end,
			setGearboxInfo = function() end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(manualClutchGearboxInfo)
		gearboxAdapter:setClutchState(0) -- not pressed
		gearboxAdapter:setGearGroupInput(1)
		gearboxAdapter:setGearInput(1)

		-- THEN
		assert.is_true(wasGroupWarningCalled)
		assert.is_true(wasGearWarningCalled)
	end)

	it("should queue gear/group changes when necessary and supported", function()
		-- GIVEN
		mockClutchIsEnabled = true
		local manualClutchGearboxInfo = VehicleGearboxInfo.new(false, true, true, 3, 6, 1)
		local wasApplyChangesCalled = false
		local wasShowClutchWarningForGroupChangeCalled = false
		local wasShowClutchWarningForGearChangeCalled = false
		local dummyGearChangeImpl = {
			applyChanges = function() wasApplyChangesCalled = true end,
			showClutchWarningForGroupChange = function() wasShowClutchWarningForGroupChangeCalled = true end,
			showClutchWarningForGearChange = function() wasShowClutchWarningForGearChangeCalled = true end,
			showManualDirectionChangeWarning = function() end
		}
		gearboxAdapter.gearChangeImpl = dummyGearChangeImpl
		-- Simulate an input strategy which supports Queueing, so without clutch presses, changes should be queued until the clutch is pressed
		local mockInputStrategy = {
			supportsQueueingForGears = function() return true end,
			supportsQueueingForGroups = function() return true end,
			setGearboxInfo = function() end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(manualClutchGearboxInfo)
		gearboxAdapter:setClutchState(0) -- not pressed
		gearboxAdapter:setGearGroupInput(42)
		gearboxAdapter:setGearInput(42)

		-- THEN
		assert.is_false(wasApplyChangesCalled)
		assert.is_false(wasShowClutchWarningForGroupChangeCalled)
		assert.is_false(wasShowClutchWarningForGearChangeCalled)
		assert.are.equal(42, gearboxAdapter.currentShifterInputData.currentGroup)
		assert.are.equal(42, gearboxAdapter.currentShifterInputData.currentGearSlot)
	end)

	it("should process queued gear/group changes when the clutch is pressed", function()
		-- GIVEN
		mockClutchIsEnabled = true
		local manualClutchGearboxInfo = VehicleGearboxInfo.new(false, true, true, 3, 6, 1)
		local dummyGearChangeImpl = {
			applyChanges = function() error("Should not be called") end,
			showClutchWarningForGroupChange = function() error("Should not be called") end,
			showClutchWarningForGearChange = function() error("Should not be called") end,
			showManualDirectionChangeWarning = function() error("Should not be called") end
		}
		gearboxAdapter.gearChangeImpl = dummyGearChangeImpl

		local fakeGearSelectionHint = GearSelectionHint.new(1, 2, 3, 4, 5)
		local actualShifterInputData = nil
		local mockInputStrategy = {
			supportsQueueingForGears = function() return true end,
			supportsQueueingForGroups = function() return true end,
			setGearboxInfo = function() end,
			calculateEffectiveGear = function(self, shifterInputData)
				actualShifterInputData = shifterInputData
				return fakeGearSelectionHint
			end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		local actualGearSelectionHint = nil
		local mockOutputStrategy = {
			calculateGearSelection = function(self, gearSelectionHint, gearboxInfo)
				actualGearSelectionHint = gearSelectionHint
				return nil
			end
		}
		gearboxAdapter.activeOutputStrategy = mockOutputStrategy

		gearboxAdapter:setGearboxInfo(manualClutchGearboxInfo)
		gearboxAdapter:setClutchState(0) -- not pressed
		gearboxAdapter:setGearGroupInput(42)
		gearboxAdapter:setGearInput(42)

		-- WHEN
		gearboxAdapter:setClutchState(1) -- pressed

		-- THEN
		assert.is_not_nil(actualShifterInputData)
		assert.are.equals(42, actualShifterInputData.currentGroup)
		assert.are.equals(42, actualShifterInputData.currentGearSlot)
		assert.is_true(actualShifterInputData.clutchIsPressed)

		assert.are.equals(fakeGearSelectionHint, actualGearSelectionHint)
	end)

	it("should always apply gear changes when the clutch is disabled in the settings", function()
		-- GIVEN
		mockClutchIsEnabled = false
		local manualClutchGearboxInfo = VehicleGearboxInfo.new(false, true, true, 3, 6, 1)
		local calculationWasTriggered = false

		local mockInputStrategy = {
			supportsQueueingForGears = function() return false end,
			supportsQueueingForGroups = function() return false end,
			setGearboxInfo = function() end,
			calculateEffectiveGear = function(self, shifterInputData)
				calculationWasTriggered = true
				return GearSelectionHint.new(1, 2, 3, 4, 5)
			end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		local mockOutputStrategy = {
			calculateGearSelection = function(self, gearSelectionHint, gearboxInfo)
				-- Abort; it's enough to know the calculation was triggered
				return nil
			end
		}
		gearboxAdapter.activeOutputStrategy = mockOutputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(manualClutchGearboxInfo)
		gearboxAdapter:setClutchState(0) -- not pressed (but clutch is disabled in settings)
		gearboxAdapter:setGearInput(42)

		-- THEN
		assert.is_true(calculationWasTriggered)
	end)

	it("should always apply group changes when the clutch is disabled in the settings", function()
		-- GIVEN
		mockClutchIsEnabled = false
		local manualClutchGearboxInfo = VehicleGearboxInfo.new(false, true, true, 3, 6, 1)
		local calculationWasTriggered = false

		local mockInputStrategy = {
			supportsQueueingForGears = function() return false end,
			supportsQueueingForGroups = function() return false end,
			setGearboxInfo = function() end,
			calculateEffectiveGear = function(self, shifterInputData)
				calculationWasTriggered = true
				return GearSelectionHint.new(1, 2, 3, 4, 5)
			end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		local mockOutputStrategy = {
			calculateGearSelection = function(self, gearSelectionHint, gearboxInfo)
				-- Abort; it's enough to know the calculation was triggered
				return nil
			end
		}
		gearboxAdapter.activeOutputStrategy = mockOutputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(manualClutchGearboxInfo)
		gearboxAdapter:setClutchState(0) -- not pressed (but clutch is disabled in settings)
		gearboxAdapter:setGearGroupInput(42)

		-- THEN
		assert.is_true(calculationWasTriggered)
	end)

	it("should always allow changing to neutral gear even without the clutch", function()
		-- GIVEN
		mockClutchIsEnabled = true
		local manualClutchGearboxInfo = VehicleGearboxInfo.new(false, true, true, 3, 6, 1)
		local calculationWasTriggered = false

		local mockInputStrategy = {
			supportsQueueingForGears = function() return false end,
			supportsQueueingForGroups = function() return false end,
			setGearboxInfo = function() end,
			calculateEffectiveGear = function(self, shifterInputData)
				calculationWasTriggered = true
				return GearSelectionHint.new(1, 2, 0, 4, 5) -- Neutral gear is 0
			end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		local mockOutputStrategy = {
			calculateGearSelection = function(self, gearSelectionHint, gearboxInfo)
				-- Abort; it's enough to know the calculation was triggered
				return nil
			end
		}
		gearboxAdapter.activeOutputStrategy = mockOutputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(manualClutchGearboxInfo)
		gearboxAdapter:setClutchState(0) -- not pressed
		gearboxAdapter:setGearInput(0) -- Neutral

		-- THEN
		assert.is_true(calculationWasTriggered)
	end)

	it("should never shift into neutral for powershift transmission", function()
		-- GIVEN
		mockClutchIsEnabled = true
		local powershiftGearboxInfo = VehicleGearboxInfo.new(false, true, false, 3, 6, 1)
		local calculationWasTriggered = false

		local mockInputStrategy = {
			supportsQueueingForGears = function() return false end,
			supportsQueueingForGroups = function() return false end,
			setGearboxInfo = function() end,
			calculateEffectiveGear = function(self, shifterInputData)
				calculationWasTriggered = true
				-- Simulate a neutral gear
				return GearSelectionHint.new(0, 0, 12, 1, 0)
			end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		local mockOutputStrategy = {
			calculateGearSelection = function(self, gearSelectionHint, gearboxInfo)
				-- Abort; it's enough to know if the calculation was triggered
				return nil
			end
		}
		gearboxAdapter.activeOutputStrategy = mockOutputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(powershiftGearboxInfo)
		gearboxAdapter:setClutchState(0) -- not pressed
		gearboxAdapter:setGearInput(0) -- Neutral

		-- THEN
		assert.is_false(calculationWasTriggered)
	end)

	it("should ignore clutch presses for CVT vehicles", function()
		-- GIVEN
		mockClutchIsEnabled = true
		local cvtGearboxInfo = VehicleGearboxInfo.new(true, false, false, 0, 0, 0)
		local calculationWasTriggered = false

		local mockInputStrategy = {
			supportsQueueingForGears = function() return false end,
			supportsQueueingForGroups = function() return false end,
			setGearboxInfo = function() end,
			calculateEffectiveGear = function() 
				calculationWasTriggered = true
				return GearSelectionHint.new(0, 0, 0, 0, 0)
			 end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(cvtGearboxInfo)
		gearboxAdapter:setClutchState(1) -- pressed

		-- THEN
		assert.is_false(calculationWasTriggered)
	end)

	it("should not crash when input arrives too early", function()
		-- GIVEN
		gearboxAdapter.activeInputStrategy = nil
		gearboxAdapter.activeOutputStrategy = nil
		gearboxAdapter.vehicleGearboxInfo = VehicleGearboxInfo.new(false, true, true, 3, 6, 1)

		-- WHEN / THEN
		assert.no_error(function() gearboxAdapter:setClutchState(1) end)
		assert.no_error(function() gearboxAdapter:setGearGroupInput(1) end)
		assert.no_error(function() gearboxAdapter:setGearInput(1) end)
		assert.no_error(function() gearboxAdapter:setClutchState(0) end)

	end)

	it("should not use reverse gears for vehicles which manually change direction", function()
		-- GIVEN
		mockClutchIsEnabled = false
		local manualDirectionChangeGearboxInfo = VehicleGearboxInfo.new(false, false, false, 3, 6, 0)
		local wasManualDirectionChangeWarningCalled = false
		local dummyGearChangeImpl = {
			applyChanges = function() end,
			showClutchWarningForGroupChange = function() end,
			showClutchWarningForGearChange = function() end,
			showManualDirectionChangeWarning = function() wasManualDirectionChangeWarningCalled = true end
		}
		gearboxAdapter.gearChangeImpl = dummyGearChangeImpl

		local mockInputStrategy = {
			supportsQueueingForGears = function() return false end,
			supportsQueueingForGroups = function() return false end,
			setGearboxInfo = function() end,
			calculateEffectiveGear = function(self, shifterInputData)
				-- Simulate R1 gear in reverse group 1
				return GearSelectionHint.new(-1, 1, 16, -1, 1)
			end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy
		gearboxAdapter.activeOutputStrategy = SequentialOutputStrategy.new()

		-- WHEN
		gearboxAdapter:setGearboxInfo(manualDirectionChangeGearboxInfo)
		gearboxAdapter:setGearInput(-1) -- Reverse gear

		-- THEN
		assert.is_true(wasManualDirectionChangeWarningCalled)
	end)

	it("should apply gear changes on valid values", function()
		-- GIVEN
		mockClutchIsEnabled = true
		local validGearboxInfo = VehicleGearboxInfo.new(false, false, false, 3, 6, 1)
		local wasApplyChangesCalled = false

		gearboxAdapter:setInputStrategy(GearboxAdapterInterface.INPUT_STRATEGY.EATON_FULLER_18)
		gearboxAdapter:setOutputStrategy(GearboxAdapterInterface.OUTPUT_STRATEGY.SEQUENTIAL)
		gearboxAdapter:setGearboxInfo(validGearboxInfo)

		local dummyGearChangeImpl = {
			applyChanges = function() wasApplyChangesCalled = true end,
			showClutchWarningForGroupChange = function() end,
			showClutchWarningForGearChange = function() end,
			showManualDirectionChangeWarning = function() end
		}
		gearboxAdapter.gearChangeImpl = dummyGearChangeImpl

		-- WHEN
		gearboxAdapter:setClutchState(1) -- pressed
		gearboxAdapter:setGearGroupInput(2)
		gearboxAdapter:setGearInput(3)
		gearboxAdapter:setClutchState(0) -- released

		-- THEN
		assert.is_true(wasApplyChangesCalled)
	end)

	it("should limit the effective gear if it exceeds the amount of gears in the vehicle", function()
		-- GIVEN
		mockClutchIsEnabled = false
		local maxVehicleGear = 12
		local gearboxInfo = VehicleGearboxInfo.new(false, false, false, 1, maxVehicleGear, 1)

		local mockInputStrategy = {
			supportsQueueingForGears = function() return false end,
			supportsQueueingForGroups = function() return false end,
			setGearboxInfo = function() end,
			calculateEffectiveGear = function(self, shifterInputData)
				-- Simulate a gear which exceeds what the vehicle can handle
				return GearSelectionHint.new(1, 16, 1, 1, 16)
			end
		}
		gearboxAdapter.activeInputStrategy = mockInputStrategy

		local mockOutputStrategy = {
			calculateGearSelection = function(self, gearSelectionHint, gearboxInfo)
				-- Assert that the effective gear was limited to the max gear of the vehicle
				assert.are.equals(maxVehicleGear, gearSelectionHint.effectiveGear)
				return nil
			end
		}
		gearboxAdapter.activeOutputStrategy = mockOutputStrategy

		-- WHEN
		gearboxAdapter:setGearboxInfo(gearboxInfo)
		gearboxAdapter:setGearInput(16) -- Trigger calculation (the value doesn't actually matter)

		-- THEN
		-- Assertions are done in the mockOutputStrategy
	end)
end)