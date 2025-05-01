local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TynaRan/Imgui/refs/heads/main/library.lua"))()
local Window = library:AddWindow("Preview", {
		main_color = Color3.fromRGB(41, 74, 122),
		min_size = Vector2.new(500, 600),
		toggle_key = Enum.KeyCode.RightShift,
		can_resize = true,
	})
	local Tab = Window:AddTab("Tab 1")

local Switch = Tab:AddSwitch("Switch", function(bool)
			print(bool)
		end)
		Switch:Set(true)

Tab:AddButton("Button", function()
			print("Button clicked.")
		end)

local Slider = Tab:AddSlider("Slider", function(x)
			print(x)
		end, { -- (options are optional)
			["min"] = 0, -- Default: 0
			["max"] = 100, -- Default: 100
			["readonly"] = false, -- Default: false
		})
