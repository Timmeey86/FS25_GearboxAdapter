---This class is responsible for providing settings in the user interface
---@class SettingsUi
---@field settings table @The settings object
---@field isInitialized boolean @Whether the UI has been initialized with settings
---@field controls table @The UI controls, indexed by the setting name
---@field gearboxAdapter GearboxAdapterInterface @Used for telling the domain core about the strategies to be used.
SettingsUi = {}
local SettingsUi_mt = Class(SettingsUi)

---Constructor
---@param gearboxAdapter GearboxAdapterInterface @Used for telling the domain core about the strategies to be used.
---@return SettingsUi
function SettingsUi.new(gearboxAdapter)
	local self = setmetatable({}, SettingsUi_mt)
	self.settings = nil
	self.controls = {}
	self.sectionTitle = nil
	self.isInitialized = false
	self.gearboxAdapter = gearboxAdapter
	return self
end

---Injects Settings into the base game settings dialog
---@param settings GearboxAdapterSettings @the settings object which shall be bound to the UI controls
function SettingsUi:injectUiSettings(settings)
	self.settings = settings
	if self.isInitialized then
		return
	end
	self.isInitialized = true

	local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings

	-- Must match GearboxAdapterInterface.INPUT_STRATEGY and OUTPUT_STRATEGY
	local inputStrategyValues = {
		"ga_inputStrategy_ef18",
		"ga_inputStrategy_ef13",
		"ga_inputStrategy_ef10",
		"ga_inputStrategy_scania12",
		"ga_inputStrategy_volvo12",
		"ga_inputStrategy_zf12",
		"ga_inputStrategy_zf16",
		"ga_inputStrategy_gearsAndGroups"
	}
	local outputStrategyValues = {
		"ga_outputStrategy_sequential"
	}

	-- Define the UI controls. For bool values, supply just the name, for ranges, supply min, max and step, and for choices, supply a values table
	-- For every name, a <prefix>_<name>_long and _short text must exist in the l10n files
	-- The _short text will be the title of the setting, the _long" text will be its tool tip
	-- For each control, a on_<name>_changed callback will be called on change
	local controlDefs = {
		{ name = "InputTransformationStrategy", values = inputStrategyValues, autoBind = true },
		{ name = "OutputTransformationStrategy", values = outputStrategyValues, autoBind = true }
	}

	UIHelper.createControlsDynamically(settingsPage, "ga_sectionTitle", self, controlDefs, "ga_")
	UIHelper.setupAutoBindControls(self, self.settings, SettingsUi.onSettingsChanged)

	-- Apply initial values
	self:updateUiElements()
end

function SettingsUi:onSettingsChanged(control)
	-- Update just in case we need to disable something
	self:updateUiElements()

	if control.name == "InputTransformationStrategy" then
		self.gearboxAdapter:setInputStrategy(self.settings.InputTransformationStrategy)
	elseif control.name == "OutputTransformationStrategy" then
		self.gearboxAdapter:setOutputStrategy(self.settings.OutputTransformationStrategy)
	end

	printf("Control '%s' was changed to value '%s'", control.name, self.settings[control.name])
end

---Updates the UI elements to reflect the current settings
function SettingsUi:updateUiElements()

	-- Note: This method is created dynamically by UIHelper.setupAutoBindControls
	self.populateAutoBindControls()

	-- Update the focus manager
	local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings
	settingsPage.generalSettingsLayout:invalidateLayout()
end