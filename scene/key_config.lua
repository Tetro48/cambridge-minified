local KeyConfigScene = Scene:extend()

KeyConfigScene.title = "Key Config"

require 'load.save'

local configurable_game_inputs = {
	"left",
	"right",
	"up",
	"down",
	"rotate_left",
	"rotate_left2",
	"rotate_right",
	"rotate_right2",
	"rotate_180",
	"hold",
	"retry",
	"pause",
	"mode_exit",
	"frame_step",
	"generic_1",
	"generic_2",
	"generic_3",
	"generic_4",
}
local configurable_system_inputs = {
	"menu_decide",
	"menu_back",
	"menu_left",
	"menu_right",
	"menu_up",
	"menu_down",
	-- "screenshot"
}
local hardcoded_system_inputs = {
	"menu_back", menu_back = "escape (except in gameplay)",
	"tas_mode", tas_mode = "f1",
	"configure_inputs", configure_inputs = "f2",
	"save_state", save_state = "f4",
	"load_state", load_state = "f5",
	"secret", secret = "???",
	"fullscreen", fullscreen = "f11",
	"screenshot", screenshot = "f12",
}
local input_naming = {
	--System Inputs
	menu_decide = "Menu Decide",
	menu_back = "Menu Back",
	menu_left = "Navigate Left",
	menu_right = "Navigate Right",
	menu_up = "Navigate Up",
	menu_down = "Navigate Down",
	tas_mode = "Toggle TAS mode",
	configure_inputs = "Configure inputs",
	save_state = "Save game state",
	load_state = "Load game state",
	secret = "???",
	fullscreen = "Toggle Fullscreen",
	screenshot = "Screenshot",
	--Game Inputs
	left = "Move Left",
	right = "Move Right",
	up = "Hard Drop (Up)",
	down = "Soft Drop (Down)",
	rotate_left = "Rotate CCW [1]",
	rotate_left2 = "Rotate CCW [2]",
	rotate_right = "Rotate CW [1]",
	rotate_right2 = "Rotate CW [2]",
	rotate_180 = "Rotate 180",
	hold = "Hold",
	retry = "Retry",
	pause = "Pause",
	mode_exit = "Exit Mode",
	frame_step = "Frame Step",
	generic_1 = "Generic 1",
	generic_2 = "Generic 2",
	generic_3 = "Generic 3",
	generic_4 = "Generic 4",
}

--A list of inputs that shouldn't have the same keybinds with the other.
local mutually_exclusive_inputs = {
	menu_decide = "menu_back",
	left = {"right", "up", "down"},
	right = {"left", "up", "down"},
	up = {"down", "left", "right"},
	down = {"left", "up", "right"},
	menu_left = {"menu_right", "menu_up", "menu_down"},
	menu_right = {"menu_left", "menu_up", "menu_down"},
	menu_up = {"menu_down", "menu_left", "menu_right"},
	menu_down = {"menu_left", "menu_up", "menu_right"},
}

function KeyConfigScene:mutexCheck(input, keybind)
	for key, value in pairs(mutually_exclusive_inputs) do
		if key == input then
			if type(value) == "table" then
				for k2, v2 in pairs(value) do
					if self.new_input[v2] == keybind then
						return true
					end
				end
			end
			if self.new_input[value] == keybind then
				return true
			end
		elseif value == input then
			if self.new_input[key] == keybind then
				return true
			end
		end
	end
	return false
end

local function newSetInputs()
	local set_inputs = {}
	for i, input in ipairs(configurable_game_inputs) do
		set_inputs[input] = false
	end
	for i, input in ipairs(configurable_system_inputs) do
		set_inputs[input] = false
	end
	return set_inputs
end

function KeyConfigScene:new()
	self.input_state = 1
	self.set_inputs = newSetInputs()
	self.new_input = {}

	if not config.input then
		config.input = {}
		self.configurable_inputs = configurable_system_inputs
	end
	if config.input.keys then
		self.reconfiguration = true
		self.new_input = config.input.keys
		for input_name, key in pairs(config.input.keys) do
			self.set_inputs[input_name] = self:formatKey(key)
		end
	end

	self.menu_state = 1

	self.safety_frames = 0
end

function KeyConfigScene:update()
	self.safety_frames = self.safety_frames - 1
end

function KeyConfigScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	drawBackground("options_input")
	if self.reconfiguration and not self.configurable_inputs then

		love.graphics.setFont(font_8x11)
		love.graphics.print("KEY CONFIG", 80, 43)

		if config.input then
			local b = cursorHighlight(20, 40, 50, 30)
			love.graphics.setColor(1, 1, b, 1)
			love.graphics.printf("<-", font_3x5_4, 20, 40, 50, "center")
			love.graphics.setColor(1, 1, 1, 1)
		end

		love.graphics.setFont(font_3x5_2)
		love.graphics.print("Which controls do you want to configure?", 80, 90)

		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.rectangle("fill", 75, 118 + 50 * self.menu_state, 200, 33)

		love.graphics.setFont(font_3x5_3)
		love.graphics.setColor(1, 1, 1, 1)
		local b = cursorHighlight(80,170,200,50)
		love.graphics.setColor(1,1,b,1)
		love.graphics.printf("Game Inputs", 80, 170, 200, "left")
		local b = cursorHighlight(80,220,200,50)
		love.graphics.setColor(1,1,b,1)
		love.graphics.printf("System Inputs", 80, 220, 200, "left")
		return
	end
	love.graphics.setFont(font_3x5_2)
	for i, input in ipairs(self.configurable_inputs) do
		if i == self.input_state then
			love.graphics.setColor(1, 1, 0, 1)
		end
		love.graphics.printf(input_naming[input], 40, 50 + i * 18, 200, "left")
		love.graphics.setColor(1, 1, 1, 1)
		if self.set_inputs[input] then
			love.graphics.printf(self.set_inputs[input], 240, 50 + i * 18, 300, "left")
		end
	end
	if self.configurable_inputs == configurable_system_inputs then
		local offset_y = #configurable_system_inputs * 18 + 75
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("- Hardcoded, executed first:", 20, offset_y, 300, "left")
		for i, input in ipairs(hardcoded_system_inputs) do
			love.graphics.printf(input_naming[input], 40, offset_y + i * 18, 200, "left")
			love.graphics.printf(hardcoded_system_inputs[input], 240, offset_y + i * 18, 300, "left")
		end
	end
	local string_press_key = "Press key input for " .. (input_naming[self.configurable_inputs[self.input_state]] or "???")
	if self.input_state > #self.configurable_inputs then
		love.graphics.print("Press enter to confirm, delete/backspace to retry" .. (config.input and ", escape to cancel" or ""))
		return
	elseif self.reconfiguration then
		if self.key_rebinding then
			love.graphics.printf(string_press_key .. ", tab to erase.", 0, 0, 640, "left")
		end
		love.graphics.printf("Press escape to exit while not rebinding. Auto-saves after you rebound a key.", 0, 20, 640, "left")
	else
		love.graphics.printf(string_press_key .. ", tab to skip.", 0, 0, 640, "left")
	end
	love.graphics.printf("Function keys (F1, F2, etc.), and tab can't be changed", 0, 40, 640, "left")
end

function KeyConfigScene:formatKey(scancode)
	if love.keyboard.getKeyFromScancode(scancode) == scancode then
		return "key ".. scancode
	else
		return "key " .. love.keyboard.getKeyFromScancode(scancode) .. ", scancode (" .. scancode .. ")"
	end
end

function KeyConfigScene:rebindKey(key)
	if key == nil then
		self.new_input[self.configurable_inputs[self.input_state]] = nil
		self.set_inputs[self.configurable_inputs[self.input_state]] = "erased"
		return true
	end
	if self:mutexCheck(self.configurable_inputs[self.input_state], key) then
		self.set_inputs[self.configurable_inputs[self.input_state]] = "<press an other key>"
		return false
	end
	self.set_inputs[self.configurable_inputs[self.input_state]] = self:formatKey(key)
	self.new_input[self.configurable_inputs[self.input_state]] = key
	return true
end

function KeyConfigScene:refreshInputStates()
	for input_name, key in pairs(self.new_input) do
		self.set_inputs[input_name] = self:formatKey(key)
	end
end

function KeyConfigScene:onInputPress(e)
	if self.safety_frames > 0 then
		return
	end
	self.safety_frames = 2
	if e.type == "key" then
		-- function keys, and tab are reserved and can't be remapped
		if self.configurable_inputs == nil then
			if e.scancode == "return" or e.scancode == "kpenter" then
				self.input_state = 1
				self.configurable_inputs = self.menu_state == 1 and configurable_game_inputs or configurable_system_inputs
				playSE("main_decide")
			end
			if e.scancode == "escape" then
				playSE("menu_cancel")
				scene = InputConfigScene()
			end
			if e.scancode == "up" then
				self.menu_state = Mod1(self.menu_state - 1, 2)
				playSE("cursor")
			end
			if e.scancode == "down" then
				self.menu_state = Mod1(self.menu_state + 1, 2)
				playSE("cursor")
			end
		elseif self.reconfiguration then
			if self.key_rebinding then
				if e.scancode == "tab" then
					self:rebindKey(nil) --this is done on purpose
					self.key_rebinding = false
				else
					if self:rebindKey(e.scancode) then
						playSE("mode_decide")
						self.key_rebinding = false
					else
						playSE("error")
					end
				end
				config.input.keys = self.new_input
				saveConfig()
			else
				if e.scancode == "escape" then
					playSE("menu_cancel")
					self.configurable_inputs = nil
				elseif e.scancode == "up" then
					playSE("cursor")
					self.input_state = Mod1(self.input_state - 1, #self.configurable_inputs)
				elseif e.scancode == "down" then
					playSE("cursor")
					self.input_state = Mod1(self.input_state + 1, #self.configurable_inputs)
				elseif e.scancode == "return" or e.scancode == "kpenter" then
					playSE("main_decide")
					self.set_inputs[self.configurable_inputs[self.input_state]] = "<press a key>"
					self.key_rebinding = true
				end
			end
		elseif self.input_state > #self.configurable_inputs then
			if e.scancode == "return" then
				-- save new input, then load next scene
				local had_config = config.input ~= nil
				if not config.input then config.input = {} end
				config.input.keys = self.new_input
				saveConfig()
				scene = had_config and InputConfigScene() or TitleScene()
			elseif e.scancode == "delete" or e.scancode == "backspace" then
				-- retry
				self.input_state = 1
				self.set_inputs = newSetInputs()
				self.new_input = {}
			end
		elseif e.scancode == "tab" then
			self.set_inputs[self.configurable_inputs[self.input_state]] = "skipped"
			self.input_state = self.input_state + 1
		-- all other keys can be configured
		elseif self:rebindKey(e.scancode) then
			self.input_state = self.input_state + 1
		else
			playSE("error")
		end
	elseif e.type == "mouse" then
		if self.configurable_inputs == nil then
			if cursorHoverArea(20, 40, 50, 30) then
				playSE("menu_cancel")
				scene = InputConfigScene()
			end
			if cursorHoverArea(80,170,200,50) then
				playSE("main_decide")
				self.configurable_inputs = configurable_game_inputs
			end
			if cursorHoverArea(80,220,200,50) then
				playSE("main_decide")
				self.configurable_inputs = configurable_system_inputs
			end
		end
	end
end

return KeyConfigScene
