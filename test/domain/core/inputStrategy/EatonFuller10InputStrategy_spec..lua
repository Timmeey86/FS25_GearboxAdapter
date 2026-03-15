dofile("src/domain/data/ShifterInputData.lua")
dofile("src/domain/data/GearSelectionHint.lua")
dofile("src/domain/core/InputTransformationStrategy.lua")
dofile("src/domain/core/inputStrategy/EatonFuller10InputStrategy.lua")

describe("Eaton Fuller 10 input strategy", function()
	it("should calculate values as expected", function()
		-- GIVEN
		local inputsAndExpectedOutputs = {
			-- Note: Reverse gears should output one group with 4 gears, rather than 4 groups with 1 gear since vehicles usually only have one reverse group
			-- low range
			{ name = "RL (L splitter)", group = 1, slot = 1, expectedDirection = -1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup = 1 },
			{ name = "RL (H splitter)", group = 2, slot = 1, expectedDirection = -1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup = 1 },
			{ name = "1 (L splitter)",  group = 1, slot = 2, expectedDirection =  1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup = 1 },
			{ name = "1 (H splitter)",  group = 2, slot = 2, expectedDirection =  1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup = 1 },
			{ name = "2 (L splitter)",  group = 1, slot = 3, expectedDirection =  1, expectedEffectiveGear =  2, expectedGroup = 1, expectedGearInGroup = 2 },
			{ name = "2 (H splitter)",  group = 2, slot = 3, expectedDirection =  1, expectedEffectiveGear =  2, expectedGroup = 1, expectedGearInGroup = 2 },
			{ name = "3 (L splitter)",  group = 1, slot = 4, expectedDirection =  1, expectedEffectiveGear =  3, expectedGroup = 1, expectedGearInGroup = 3 },
			{ name = "3 (H splitter)",  group = 2, slot = 4, expectedDirection =  1, expectedEffectiveGear =  3, expectedGroup = 1, expectedGearInGroup = 3 },
			{ name = "4 (L splitter)",  group = 1, slot = 5, expectedDirection =  1, expectedEffectiveGear =  4, expectedGroup = 1, expectedGearInGroup = 4 },
			{ name = "4 (H splitter)",  group = 2, slot = 5, expectedDirection =  1, expectedEffectiveGear =  4, expectedGroup = 1, expectedGearInGroup = 4 },
			{ name = "5 (L splitter)",  group = 1, slot = 6, expectedDirection =  1, expectedEffectiveGear =  5, expectedGroup = 1, expectedGearInGroup = 5 },
			{ name = "5 (H splitter)",  group = 2, slot = 6, expectedDirection =  1, expectedEffectiveGear =  5, expectedGroup = 1, expectedGearInGroup = 5 },
			-- high range
			{ name = "RH (L splitter)", group = 3, slot = 1, expectedDirection = -1, expectedEffectiveGear =  2, expectedGroup = 1, expectedGearInGroup = 2 },
			{ name = "RH (H splitter)", group = 4, slot = 1, expectedDirection = -1, expectedEffectiveGear =  2, expectedGroup = 1, expectedGearInGroup = 2 },
			{ name = "6 (L splitter)",  group = 3, slot = 2, expectedDirection =  1, expectedEffectiveGear =  6, expectedGroup = 2, expectedGearInGroup = 1 },
			{ name = "6 (H splitter)",  group = 4, slot = 2, expectedDirection =  1, expectedEffectiveGear =  6, expectedGroup = 2, expectedGearInGroup = 1 },
			{ name = "7 (L splitter)",  group = 3, slot = 3, expectedDirection =  1, expectedEffectiveGear =  7, expectedGroup = 2, expectedGearInGroup = 2 },
			{ name = "7 (H splitter)",  group = 4, slot = 3, expectedDirection =  1, expectedEffectiveGear =  7, expectedGroup = 2, expectedGearInGroup = 2 },
			{ name = "8 (L splitter)",  group = 3, slot = 4, expectedDirection =  1, expectedEffectiveGear =  8, expectedGroup = 2, expectedGearInGroup = 3 },
			{ name = "8 (H splitter)",  group = 4, slot = 4, expectedDirection =  1, expectedEffectiveGear =  8, expectedGroup = 2, expectedGearInGroup = 3 },
			{ name = "9 (L splitter)",  group = 3, slot = 5, expectedDirection =  1, expectedEffectiveGear =  9, expectedGroup = 2, expectedGearInGroup = 4 },
			{ name = "9 (H splitter)",  group = 4, slot = 5, expectedDirection =  1, expectedEffectiveGear =  9, expectedGroup = 2, expectedGearInGroup = 4 },
			{ name = "10 (L splitter)", group = 3, slot = 6, expectedDirection =  1, expectedEffectiveGear = 10, expectedGroup = 2, expectedGearInGroup = 5 },
			{ name = "10 (H splitter)", group = 4, slot = 6, expectedDirection =  1, expectedEffectiveGear = 10, expectedGroup = 2, expectedGearInGroup = 5 },
			-- neutral (only one group)
			{ name = "Neutral (L)",     group = 1, slot = 0, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 1, expectedGearInGroup = 0 },
			{ name = "Neutral (H)",     group = 4, slot = 0, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 1, expectedGearInGroup = 0 },
			-- invalid
			{ name = "Group 5",      group = 5, slot = 1, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Group 0",      group = 0, slot = 1, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Slot 7",       group = 1, slot = 7, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 },
			{ name = "Gear+Group 0", group = 0, slot = 0, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }
		}
		local testCaseToString = function(testCase, property)
			return string.format("\n\nTest Case for gear %s:\n%s does not match.\nSimulated input: Group %d, Slot %d\n", testCase.name, property, testCase.group, testCase.slot)
		end

		local strategy = EatonFuller10InputStrategy.new()


		-- WHEN / THEN
		for i, testCase in ipairs(inputsAndExpectedOutputs) do
			-- WHEN
			local result = strategy:calculateEffectiveGear(ShifterInputData.new(testCase.group, testCase.slot, true))

			-- THEN
			assert.are.equals(testCase.expectedDirection, result.direction, testCaseToString(testCase, "expectedDirection"))
			assert.are.equals(testCase.expectedEffectiveGear, result.effectiveGear, testCaseToString(testCase, "expectedEffectiveGear"))
			assert.are.equals(testCase.expectedGroup, result.gearGroup, testCaseToString(testCase, "expectedGroup"))
			assert.are.equals(testCase.expectedGearInGroup, result.gearInGroup, testCaseToString(testCase, "expectedGearInGroup"))
			assert.are.equals(10, result.maxNumGears, testCaseToString(testCase, "expectedMaxNumGears"))
		end
	end)
end)