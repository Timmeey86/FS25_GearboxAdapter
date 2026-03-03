---This class is responsible for grabbing the configured input actions and forwarding them to the domain core.
GearInputAdapterSpec = {}

---Registers the specialization with the type manager so it can be assigned to vehicles
---@param typeManager table @The type manager to register the specialization with
---@param typeName string @The vehicle type name
---@param specializations table @The list of specializations to check for prerequisites
function GearInputAdapterSpec.register(typeManager, typeName, specializations)
	if GearInputAdapterSpec.prerequisitesPresent(specializations) then
		typeManager:addSpecialization(typeName, GearInputAdapterSpec.SPEC_NAME)
	end
end

---Initializes the specialization
function GearInputAdapterSpec.initSpecialization()
	-- Nothing to do right now
end

---Makes sure any dependent specializations are loaded
---@param specializations table @The list of specializations to check
function GearInputAdapterSpec.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Motorized, specializations)
end

---Registers custom event listenerd
---@param vehicleType table @The vehicle type to register the action events for
function GearInputAdapterSpec.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", GearInputAdapterSpec)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", GearInputAdapterSpec)
end

function GearInputAdapterSpec:onUpdateTick(dt, _, isActiveForInputIgnoreSelection, _)
	if self.isClient then
		if isActiveForInputIgnoreSelection then
			GearInputAdapterSpec.updateActionEvents(self)
		end
	end
end

function GearInputAdapterSpec:onRegisterActionEvents(_, isActiveForInputIgnoreSelection)
	if self.isClient then
		local spec = self.spec_gearInputAdapter
		self:clearActionEventsTable(spec.actionEvents)
		if isActiveForInputIgnoreSelection then
			local _, actionEventId = self:addActionEvent(spec.actionEvents, "GA_CUSTOM_STATE_1", self, GearInputAdapterSpec.onCustomState1, false, true, false, true, nil)
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_HIGH)
			g_inputBinding:setActionEventText(actionEventId, "TODO")
			local _, actionEventId = self:addActionEvent(spec.actionEvents, "GA_CUSTOM_STATE_2", self, GearInputAdapterSpec.onCustomState2, false, true, false, true, nil)
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_HIGH)
			g_inputBinding:setActionEventText(actionEventId, "TODO")
			local _, actionEventId = self:addActionEvent(spec.actionEvents, "GA_CUSTOM_STATE_3", self, GearInputAdapterSpec.onCustomState3, false, true, false, true, nil)
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_HIGH)
			g_inputBinding:setActionEventText(actionEventId, "TODO")
			local _, actionEventId = self:addActionEvent(spec.actionEvents, "GA_CUSTOM_STATE_4", self, GearInputAdapterSpec.onCustomState4, false, true, false, true, nil)
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_HIGH)
			g_inputBinding:setActionEventText(actionEventId, "TODO")
			GearInputAdapterSpec.updateActionEvents(self)
		end
	end
end

function GearInputAdapterSpec:onCustomState1(actionname, inputValue, callbackState, _)
	Logging.info("Custom state 1: %s", inputValue)
end
function GearInputAdapterSpec:onCustomState2(actionname, inputValue, callbackState, _)
	Logging.info("Custom state 2: %s", inputValue)
end
function GearInputAdapterSpec:onCustomState3(actionname, inputValue, callbackState, _)
	Logging.info("Custom state 3: %s", inputValue)
end
function GearInputAdapterSpec:onCustomState4(actionname, inputValue, callbackState, _)
	Logging.info("Custom state 4: %s", inputValue)
end

function GearInputAdapterSpec:updateActionEvents()
		local spec = self.spec_gearInputAdapter
		local actionEvent = spec.actionEvents["GA_CUSTOM_STATE_1"]
	g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
		actionEvent = spec.actionEvents["GA_CUSTOM_STATE_2"]
	g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
		actionEvent = spec.actionEvents["GA_CUSTOM_STATE_3"]
	g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
		actionEvent = spec.actionEvents["GA_CUSTOM_STATE_4"]
	g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
end