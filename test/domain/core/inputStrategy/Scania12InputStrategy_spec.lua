dofile("src/domain/data/ShifterInputData.lua")
dofile("src/domain/data/GearSelectionHint.lua")
dofile("src/domain/core/InputTransformationStrategy.lua")
dofile("src/domain/core/inputStrategy/Scania12InputStrategy.lua")

describe("Scania 12 input strategy", function()
	it("should calculate values as expected", function()
		-- GIVEN
		local inputsAndExpectedOutputs = {
			-- Note: Reverse gears should output one group with 2 gears, rather than 2 groups with 1 gear since vehicles usually only have one reverse group
			-- low range
			{ name = "RL", group = 1, slot = 1, expectedDirection = -1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup = 1 },
			{ name = "RH", group = 2, slot = 1, expectedDirection = -1, expectedEffectiveGear =  2, expectedGroup = 1, expectedGearInGroup = 2 },
			{ name = "1L", group = 1, slot = 4, expectedDirection =  1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup = 1 },
			{ name = "1H", group = 2, slot = 4, expectedDirection =  1, expectedEffectiveGear =  2, expectedGroup = 2, expectedGearInGroup = 1 },
			{ name = "2L", group = 1, slot = 5, expectedDirection =  1, expectedEffectiveGear =  3, expectedGroup = 1, expectedGearInGroup = 2 },
			{ name = "2H", group = 2, slot = 5, expectedDirection =  1, expectedEffectiveGear =  4, expectedGroup = 2, expectedGearInGroup = 2 },
			{ name = "3L", group = 1, slot = 6, expectedDirection =  1, expectedEffectiveGear =  5, expectedGroup = 1, expectedGearInGroup = 3 },
			{ name = "3H", group = 2, slot = 6, expectedDirection =  1, expectedEffectiveGear =  6, expectedGroup = 2, expectedGearInGroup = 3 },
			-- high range
			{ name = "4L", group = 3, slot = 4, expectedDirection =  1, expectedEffectiveGear =  7, expectedGroup = 3, expectedGearInGroup = 1 },
			{ name = "4H", group = 4, slot = 4, expectedDirection =  1, expectedEffectiveGear =  8, expectedGroup = 4, expectedGearInGroup = 1 },
			{ name = "5L", group = 3, slot = 5, expectedDirection =  1, expectedEffectiveGear =  9, expectedGroup = 3, expectedGearInGroup = 2 },
			{ name = "5H", group = 4, slot = 5, expectedDirection =  1, expectedEffectiveGear = 10, expectedGroup = 4, expectedGearInGroup = 2 },
			{ name = "6L", group = 3, slot = 6, expectedDirection =  1, expectedEffectiveGear = 11, expectedGroup = 3, expectedGearInGroup = 3 },
			{ name = "6H", group = 4, slot = 6, expectedDirection =  1, expectedEffectiveGear = 12, expectedGroup = 4, expectedGearInGroup = 3 },
			-- unused (crawler gears and unused slots)
			{ name = "Slot1 HL",  group = 3, slot = 1, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Slot1 HH",  group = 4, slot = 1, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "C1",        group = 1, slot = 2, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "C2",        group = 2, slot = 2, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Slot 2 HL", group = 3, slot = 2, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Slot 2 HH", group = 4, slot = 2, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Slot 3 LL", group = 1, slot = 3, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Slot 3 HH", group = 4, slot = 3, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			-- neutral (only one group)
			{ name = "Neutral (LL)", group = 1, slot = 0, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 1, expectedGearInGroup = 0 },
			{ name = "Neutral (HH)", group = 4, slot = 0, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 1, expectedGearInGroup = 0 },
			-- invalid
			{ name = "Group 5",      group = 5, slot = 1, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Group 0",      group = 0, slot = 1, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Slot 7",       group = 1, slot = 7, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Gear+Group 0", group = 0, slot = 0, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }
		}
		local testCaseToString = function(testCase, property)
			return string.format("\n\nTest Case for gear %s:\n%s does not match.\nSimulated input: Group %d, Slot %d\n", testCase.name, property, testCase.group, testCase.slot)
		end

		local strategy = Scania12InputStrategy.new()


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
end)