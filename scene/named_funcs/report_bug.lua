local FuncScene = Scene:extend()

FuncScene.title = "RprtMfBugs"

function FuncScene:new()
	self.prev_scene = scene
	love.system.openURL("https://github.com/Tetro48/cambridge-minified/issues")
end

function FuncScene:update()
	scene = self.prev_scene
end

function FuncScene:render()
end

function FuncScene:changeOption(rel)
end

function FuncScene:onInputPress(e)
end
return FuncScene