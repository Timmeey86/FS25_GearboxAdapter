dofile("src/domain/data/ShifterInputData.lua")
dofile("src/domain/data/GearSelectionHint.lua")
dofile("src/domain/data/InputControllerInfo.lua")
dofile("src/domain/core/InputTransformationStrategy.lua")
dofile("src/domain/core/inputStrategy/GearsAndGroupsInputStrategy.lua")

describe("Gears and Groups input strategy", function()
	it("should calculate values as expected for 4 gears and 3 groups", function()
		-- GIVEN
		local inputsAndExpectedOutputs = {
			-- valid input
			{ name = "Group 1, Gear 1", group = 1, slot =  1, expectedDirection =  1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup =  1 },
			{ name = "Group 1, Gear 2", group = 1, slot =  2, expectedDirection =  1, expectedEffectiveGear =  2, expectedGroup = 1, expectedGearInGroup =  2 },
			{ name = "Group 1, Gear 3", group = 1, slot =  3, expectedDirection =  1, expectedEffectiveGear =  3, expectedGroup = 1, expectedGearInGroup =  3 },
			{ name = "Group 1, Gear 4", group = 1, slot =  4, expectedDirection =  1, expectedEffectiveGear =  4, expectedGroup = 1, expectedGearInGroup =  4 },
			{ name = "Group 2, Gear 1", group = 2, slot =  1, expectedDirection =  1, expectedEffectiveGear =  5, expectedGroup = 2, expectedGearInGroup =  1 },
			{ name = "Group 2, Gear 2", group = 2, slot =  2, expectedDirection =  1, expectedEffectiveGear =  6, expectedGroup = 2, expectedGearInGroup =  2 },
			{ name = "Group 2, Gear 3", group = 2, slot =  3, expectedDirection =  1, expectedEffectiveGear =  7, expectedGroup = 2, expectedGearInGroup =  3 },
			{ name = "Group 2, Gear 4", group = 2, slot =  4, expectedDirection =  1, expectedEffectiveGear =  8, expectedGroup = 2, expectedGearInGroup =  4 },
			{ name = "Group 3, Gear 1", group = 3, slot =  1, expectedDirection =  1, expectedEffectiveGear =  9, expectedGroup = 3, expectedGearInGroup =  1 },
			{ name = "Group 3, Gear 2", group = 3, slot =  2, expectedDirection =  1, expectedEffectiveGear = 10, expectedGroup = 3, expectedGearInGroup =  2 },
			{ name = "Group 3, Gear 3", group = 3, slot =  3, expectedDirection =  1, expectedEffectiveGear = 11, expectedGroup = 3, expectedGearInGroup =  3 },
			{ name = "Group 3, Gear 4", group = 3, slot =  4, expectedDirection =  1, expectedEffectiveGear = 12, expectedGroup = 3, expectedGearInGroup =  4 },
			{ name = "Group 1, Gear R", group = 1, slot = -1, expectedDirection = -1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup =  1 },
			{ name = "Group 1, Gear N", group = 1, slot =  0, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 1, expectedGearInGroup =  0 },
			-- invalid input
			{ name = "Group 0, Gear 1", group = 0, slot = 1, expectedDirection = 0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Group 4, Gear 1", group = 4, slot = 1, expectedDirection = 0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Group 1, Gear 5", group = 1, slot = 5, expectedDirection = 0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }
		}
		local testCaseToString = function(testCase, property)
			return string.format("\n\nTest Case for gear %s:\n%s does not match.\nSimulated input: Group %d, Slot %d\n", testCase.name, property, testCase.group, testCase.slot)
		end

		local strategy = GearsAndGroupsInputStrategy.new()
		strategy:setInputControllerInfo(InputControllerInfo.new(3, 4))


		-- WHEN / THEN
		for i, testCase in ipairs(inputsAndExpectedOutputs) do
			-- WHEN
			local result = strategy:calculateEffectiveGear(ShifterInputData.new(testCase.group, testCase.slot, true))

			-- THEN
			assert.are.equals(testCase.expectedDirection, result.direction, testCaseToString(testCase, "expectedDirection"))
			assert.are.equals(testCase.expectedEffectiveGear, result.effectiveGear, testCaseToString(testCase, "expectedEffectiveGear"))
			assert.are.equals(testCase.expectedGroup, result.gearGroup, testCaseToString(testCase, "expectedGroup"))
			assert.are.equals(testCase.expectedGearInGroup, result.gearInGroup, testCaseToString(testCase, "expectedGearInGroup"))
			assert.are.equals(12, result.maxNumGears, testCaseToString(testCase, "expectedMaxNumGears"))
		end
	end)

	it("should work for different groups", function()
		-- GIVEN
		local strategy = GearsAndGroupsInputStrategy.new()

		-- WHEN
		strategy:setInputControllerInfo(InputControllerInfo.new(4, 6))
		local selectionHint = strategy:calculateEffectiveGear(ShifterInputData.new(4, 6, true))
		assert.are.equals(24, selectionHint.maxNumGears, "maxNumGears does not match for 4 groups and 6 gears")
		assert.are.equals(4, selectionHint.gearGroup, "gearGroup does not match for 4 groups and 6 gears (group 4 selected)")
		assert.are.equals(6, selectionHint.gearInGroup, "gearInGroup does not match for 4 groups and 6 gears (gear 6 selected)")
		assert.are.equals(24, selectionHint.effectiveGear, "effectiveGear does not match for 4 groups and 6 gears (group 4, gear 6 selected)")

		selectionHint = strategy:calculateEffectiveGear(ShifterInputData.new(2, 3, true))
		assert.are.equals(24, selectionHint.maxNumGears, "maxNumGears does not match for 4 groups and 6 gears")
		assert.are.equals(2, selectionHint.gearGroup, "gearGroup does not match for 4 groups and 6 gears (group 2 selected)")
		assert.are.equals(3, selectionHint.gearInGroup, "gearInGroup does not match for 4 groups and 6 gears (gear 3 selected)")
		assert.are.equals(9, selectionHint.effectiveGear, "effectiveGear does not match for 4 groups and 6 gears (group 2, gear 3 selected)")

		strategy:setInputControllerInfo(InputControllerInfo.new(8, 8))
		selectionHint = strategy:calculateEffectiveGear(ShifterInputData.new(8, 8, true))
		assert.are.equals(64, selectionHint.maxNumGears, "maxNumGears does not match for 8 groups and 8 gears")
		assert.are.equals(8, selectionHint.gearGroup, "gearGroup does not match for 8 groups and 8 gears (group 8 selected)")
		assert.are.equals(8, selectionHint.gearInGroup, "gearInGroup does not match for 8 groups and 8 gears (gear 8 selected)")
		assert.are.equals(64, selectionHint.effectiveGear, "effectiveGear does not match for 8 groups and 8 gears (group 8, gear 8 selected)")
	end)
end)