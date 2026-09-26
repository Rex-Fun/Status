-- sorry u get bad code cuz i wasnt paid to make this :p this should work for basic use cases tho
local lib = {
	ui = nil;
	theme = nil;

	hotkey = Enum.KeyCode.Tab;

	methods = {};
	elements = {};
	subelements = {};
	['BROWEN😂😂'] = {};

	presets = {
		def = {
			accent = Color3.fromRGB(255, 0, 245);

			bg = Color3.fromRGB(255, 255, 255);
			fg = Color3.fromRGB(245, 245, 245);

			il = Color3.fromRGB(30, 30, 30);
			ol = Color3.fromRGB(10, 10, 10);

			t = Color3.fromRGB(255, 255, 255);
			t2 = Color3.fromRGB(200, 200, 200);
		};
	};
}

lib.theme = lib.presets.def
local Client = game:GetService('Players').LocalPlayer;
local Mouse = Client:GetMouse();

lib.subelements.__index = lib.subelements;
lib.elements.__index = lib.elements;
lib.methods.__index = lib.methods;
lib.__index = lib;

local function new(class: string, properties: {}?, attributes: {}?): Instance | boolean
	local success, instance = pcall(Instance.new, class)

	if not success then
		return false
	end

	if properties then
		for key, value in next, properties do
			local succ, err = pcall(function()
				(instance :: any)[key] = value
			end)

			if not succ then
				warn(err, properties.Name)
				return nil
			end
		end
	end

	if attributes then
		for key, value in next, (attributes) do
			instance:SetAttribute(key, value)
		end
	end

	return instance
end

function lib:overwrite(T1 : {}, T2 : {}) : {}
	for i, v in next, (T2) do
		T1[i] = type(v) == 'table' and lib:overwrite(T1[i] or {}, v) or v
	end

	return T1 or nil
end

function lib:closetasks(t : {})
	for _, link in next,t do
		if typeof(link) == 'RBXScriptConnection' then
			link:Disconnect();
		else
			pcall(function()
				task.cancel(link)
			end)
		end
	end
end

function lib:coloredit(color : Color3, number : number) : Color3
	local h, s, v = color:ToHSV()
	v = math.clamp(v + (number / 255), 0, 1)
	return Color3.fromHSV(h, s, v)
end

function lib:validinput(i)
	return table.find({
		Enum.UserInputType.MouseMovement;
		Enum.UserInputType.MouseButton1;
		Enum.UserInputType.Touch;
	}, i.UserInputType)
end

lib.ui = new("ScreenGui", { Parent = game:GetService('RunService'):IsStudio() and Client.PlayerGui or game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,})

function lib.elements:butt(...)
	local Element = lib:overwrite({
		text = 'Text';
		icon = 'rbxassetid://0';
		call = print;
	}, ... or {})

	Element['im secretly a gay furry femboy but nobodys gonna read this so my secret is safe'] = new("TextButton", { Parent = self.doomdtw_is_so_cute; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.new(1, 0, 0, 16); Text = ''; TextColor3 = Color3.fromRGB(0, 0, 0); TextSize = 14; }) :: TextButton 
	new("UIGradient", { Parent = Element['im secretly a gay furry femboy but nobodys gonna read this so my secret is safe']; Color =ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)), ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18)) }; Rotation = 90; }) 
	new("UIStroke", { Parent = Element['im secretly a gay furry femboy but nobodys gonna read this so my secret is safe']; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; }) 
	new("TextLabel", { Parent = Element['im secretly a gay furry femboy but nobodys gonna read this so my secret is safe']; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.fromScale(1, 1); Text = Element.text; TextColor3 = Color3.fromRGB(200, 200, 200); TextSize = 14; }) 

	Element['im secretly a gay furry femboy but nobodys gonna read this so my secret is safe'].Activated:Connect(Element.call)

	return Element
end

function lib.elements:baee(...)
	local BRUUUUUUUUUUUUUUUUUUUUUUUUUULOLOLOLOKLOLOKLOOKOKOLJKASDLJKNASJKCNXILJNI = lib:overwrite({
		text = 'browen';
		doomdtw_is_so_cute = nil;
	}, ... or {})

	local base = new("Frame", { Parent = self.doomdtw_is_so_cute; Name = "base"; AutomaticSize =Enum.AutomaticSize.Y; BackgroundColor3 = Color3.fromRGB(20, 20, 20); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.new(1, 0, 0, 6); }) :: Frame 
	local top = new("Frame", { Parent = base; Name = "top"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; LayoutOrder = -1; Size = UDim2.new(1, 0, 0, 8); }) :: Frame 
	local LeftC = new("Frame", { Parent = top; Name = "LeftC"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.fromOffset(-16, 0); Size = UDim2.new(0, 20, 1, 0); }) :: Frame 
	local label = new("TextLabel", { Parent = LeftC; Name = "label"; AutomaticSize =Enum.AutomaticSize.X; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.fromScale(0, 1); Text = BRUUUUUUUUUUUUUUUUUUUUUUUUUULOLOLOLOKLOLOKLOOKOKOLJKASDLJKNASJKCNXILJNI.text; TextColor3 = Color3.fromRGB(200, 200, 200); TextSize = 14; }) :: TextLabel 
	local RightC = new("Frame", { Parent = top; Name = "RightC"; AnchorPoint = Vector2.new(1, 0); BackgroundColor3 = Color3.fromRGB(18, 18, 18); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.new(1, 22, 0, 0); Size = UDim2.fromScale(0, 1); }) :: Frame 
	new("UIListLayout", { Parent = LeftC; FillDirection =Enum.FillDirection.Horizontal; Padding =UDim.new(0, 6); SortOrder = Enum.SortOrder.LayoutOrder; }) 
	new("UIPadding", { Parent = label; PaddingBottom =UDim.new(0, 2); }) 
	new("UIListLayout", { Parent = RightC; FillDirection =Enum.FillDirection.Horizontal; HorizontalAlignment = Enum.HorizontalAlignment.Right; Padding =UDim.new(0, 24); SortOrder = Enum.SortOrder.LayoutOrder; }) 
	new("UIListLayout", { Parent = base; Padding =UDim.new(0, 5); SortOrder = Enum.SortOrder.LayoutOrder; });

	local Placeholder = new("Frame", { Parent = LeftC; Name = "Placeholder"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; LayoutOrder = -1; Size = UDim2.fromScale(1, 1); }) :: Frame 
	new("UIAspectRatioConstraint", { Parent = Placeholder; }) 

	BRUUUUUUUUUUUUUUUUUUUUUUUUUULOLOLOLOKLOLOKLOOKOKOLJKASDLJKNASJKCNXILJNI.c1 = LeftC;
	BRUUUUUUUUUUUUUUUUUUUUUUUUUULOLOLOLOKLOLOKLOOKOKOLJKASDLJKNASJKCNXILJNI.c2 = RightC;
	BRUUUUUUUUUUUUUUUUUUUUUUUUUULOLOLOLOKLOLOKLOOKOKOLJKASDLJKNASJKCNXILJNI.c3 = base;
	BRUUUUUUUUUUUUUUUUUUUUUUUUUULOLOLOLOKLOLOKLOOKOKOLJKASDLJKNASJKCNXILJNI.tron = Placeholder

	setmetatable(BRUUUUUUUUUUUUUUUUUUUUUUUUUULOLOLOLOKLOLOKLOOKOKOLJKASDLJKNASJKCNXILJNI, lib.subelements)
	return BRUUUUUUUUUUUUUUUUUUUUUUUUUULOLOLOLOKLOLOKLOOKOKOLJKASDLJKNASJKCNXILJNI	
end

function lib.subelements:addtog(...)
	local ElementData = lib:overwrite({
		text = 'Toggle';
		val = false;
		call = function()
		end,
	}, ... or {})

	if self.tron then
		self.tron:Destroy();
		self.tron = nil;
	end

	local doomdtwlololololololo = new("TextButton", { Parent = self.c1; Name = "doomdtwlololololololo"; LayoutOrder = -999; AutoButtonColor = false; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.fromScale(1, 1); Text = ""; TextColor3 = Color3.fromRGB(0, 0, 0); TextSize = 14; }) :: TextButton 
	new("UIAspectRatioConstraint", { Parent = doomdtwlololololololo; }) 
	new("UIStroke", { Parent = doomdtwlololololololo; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; }) 

	function ElementData:Set(Value : boolean)
		if ElementData.Children then
			ContainerFrame.Visible = Value;
		end

		doomdtwlololololololo.BackgroundColor3 = Value and (lib.theme.accent) or (Color3.fromRGB(18,18,18))
		ElementData.val = Value;
		ElementData.call(Value);
	end

	doomdtwlololololololo.Activated:Connect(function()
		ElementData:Set(not ElementData.val);
	end)

	ElementData:Set(ElementData.val);

	setmetatable(ElementData, lib.SubElements);
	return ElementData
end

function lib.subelements:addkiki(...)
	-- BOIIIIIII KIKI DO U LOVE MEEEEEEEEEE😂😂😂😂😂😂😂😂😂🧅🧅
	local ElementData = lib:overwrite({
		text = 'browne';
		mode = "Click";
		val = nil;

		changed = function() end;
		call = function() end;
		active = false;
	}, ... or {})
	setmetatable(ElementData, lib.subelements)

	local ElementButton = new("TextButton", { Parent = self.c2, AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(18, 18, 18), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), Size = UDim2.fromScale(1, 1), Text = "", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, TextTransparency = 1, }) :: TextButton 
	local ButtonLabel = new("TextLabel", { Parent = ElementButton, AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), Size = UDim2.fromScale(0, 1), Text = "...", TextColor3 = Color3.fromRGB(152, 152, 152), TextSize = 14, }) 
	new("UIStroke", { Parent = ElementButton, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, }) 
	new("UIStroke", { Parent = ElementButton, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, BorderStrokePosition = Enum.BorderStrokePosition.Inner, Color = Color3.fromRGB(28, 28, 28), }) 
	new("UIPadding", { Parent = ElementButton, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), }) 

	local function gsub(e)
		return tostring(e)
			:gsub('Enum%.KeyCode%.', '')
			:gsub('Enum%.UserInputType%.', '')
			:gsub('ouse', '')
			:gsub('utton', '')
	end

	function ElementData:Set(eeeee : string)
		local Blacklist = {
			'RightSuper',
			'LeftSuper',
			'BackSlash',
			'Backspace',
			'Unknown',
			'Return',
			'Escape',
		}

		if eeeee == nil then
			ButtonLabel.Text = '?'
			ElementData.val = nil
			return
		end

		local stripped = gsub(eeeee)

		if table.find(Blacklist, stripped) then
			ButtonLabel.Text = '?'
			ElementData.val = nil
			return
		end

		ButtonLabel.Text = gsub(eeeee)
		ElementData.val = gsub(eeeee) 
	end

	ElementButton.Activated:Connect(function()
		ElementData.Editing = true
		ButtonLabel.Text = '...'
	end)

	local KeybindBeginTask = game:GetService('UserInputService').InputBegan:Connect(function(Input, GameProcessedEvent)
		if GameProcessedEvent and not ElementData.Editing then
			return
		end

		if ElementData.Editing then
			ElementData:Set(Input.UserInputType ==Enum.UserInputType.Keyboard and gsub(Input.KeyCode) or gsub(Input.UserInputType))
			ElementData.Editing = false;
			return
		end

		if gsub(Input.KeyCode) == ElementData.val or gsub(Input.UserInputType) == ElementData.val then
			if ElementData.mode == 'Hold' then
				ElementData.pressed = true
				ElementData.active = true

				while ElementData.pressed do task.wait()
					local _, CallFailure = pcall(function()
						ElementData.call(ElementData.val)
					end)

					if CallFailure then warn(CallFailure) end
				end
			elseif ElementData.mode == 'Toggle' then
				ElementData.pressed = not ElementData.pressed
				ElementData.active = ElementData.pressed
				while ElementData.pressed do task.wait()
					local _, CallFailure = pcall(function()
						ElementData.call(ElementData.val)
					end)

					if CallFailure then warn(CallFailure) end
				end
			elseif ElementData.mode == 'Click' then
				ElementData.active = true
				local _, CallFailure = pcall(function()
					ElementData.call(ElementData.val)
				end)

				if CallFailure then warn(CallFailure) end
			end
		end
	end)

	local KeybindEndTask = game:GetService('UserInputService').InputEnded:Connect(function(Input, GPE)
		if not GPE then
			if (gsub(Input.KeyCode) == ElementData.val or gsub(Input.UserInputType) == ElementData.val) and ElementData.mode == 'Hold' then
				ElementData.pressed = false
				ElementData.active = false
			end

			if (gsub(Input.KeyCode) == ElementData.val or gsub(Input.UserInputType) == ElementData.val) and ElementData.mode == 'Click' then
				ElementData.active = false
			end
		end
	end)

	ElementData:Set(ElementData.val)
end

function lib.subelements:addtscolor(...)
	local ElementData = lib:overwrite({
		Instance = nil;
		Float = nil;
		Draggable = true;
		Dropped = false;
		Colors = {};

		text = 'Color Picker';
		val = Color3.fromRGB(255, 255, 255);
		alpha = 1;
		call = function() end;
	}, ... or {})

	local ElementButton = new("TextButton", { Parent = self.c2, BackgroundColor3 = Color3.fromRGB(255, 0, 245), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), Size = UDim2.new(0, 19, 1, 0), Text = "", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, TextTransparency = 1, }) :: TextButton 
	new("UIStroke", { Parent = ElementButton, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, }) 
	new("UIPadding", { Parent = ElementButton, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), }) 
	new("UIGradient", { Parent = ElementButton, Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(152, 152, 152)) }, Rotation = 90, }) 

	local PreviewButton = ElementButton

	local ColorPickerFrame = new("Frame", { Parent = lib.ui, Visible = false; Name = "ColorPickerFrame", BackgroundColor3 = Color3.fromRGB(13, 13, 13), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Position = UDim2.fromScale(0.7144556641578674, 0.4033333361148834), Size = UDim2.fromOffset(180, 180), }) :: Frame 
	local ColorMap = new("Frame", { Parent = ColorPickerFrame, Name = "Map", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromOffset(150, 150), }) :: Frame 
	local SatMap = new("Frame", { Parent = ColorMap, Name = "SatMap", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), }) :: Frame 
	local ValMap = new("Frame", { Parent = ColorMap, Name = "ValMap", BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), }) :: Frame 
	local ColorMarker = new("Frame", { Parent = ColorMap, Name = "MapMarker", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromOffset(4, 4), }) :: Frame 
	local HueBar = new("Frame", { Parent = ColorPickerFrame, Name = "Hue", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Position = UDim2.fromScale(1, 0), Size = UDim2.new(1, -155, 1, -18), }) :: Frame 
	local HueMarker = new("Frame", { Parent = HueBar, Name = "HueMarker", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Position = UDim2.fromScale(1, 0), Size = UDim2.new(1, 0, 0, 7), }) :: Frame 
	local AlphaBar = new("Frame", { Parent = ColorPickerFrame, Name = "Alp", AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(18, 18, 18), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, -18, 1, -155), }) :: Frame 
	local AlphaFill = new("Frame", { Parent = AlphaBar, Name = "SatMap", BackgroundColor3 = Color3.fromRGB(255, 0, 4), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), }) :: Frame 
	local AlphaMarker = new("Frame", { Parent = AlphaBar, Name = "AlpMarker", ZIndex = 999; AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 7, 1, 0), }) :: Frame 
	local CopyButton = new("TextButton", { Parent = ColorPickerFrame, AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = Color3.fromRGB(18, 18, 18), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.fromScale(1, 1), Size = UDim2.fromOffset(13, 13), Text = "C", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 14, }) :: TextButton 
	local ValueGradient=new("UIGradient", { Parent = ValMap, Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) }, Rotation = 90, Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }, }) 
	local SaturationGradient = new("UIGradient", { Parent = SatMap, Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }, }) 
	local HueGradient =	new("UIGradient", { Parent = HueBar, Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)) }, Rotation = 90, }) 
	new("UIStroke", { Parent = ColorPickerFrame, BorderStrokePosition = Enum.BorderStrokePosition.Inner, }) 
	new("UIPadding", { Parent = ColorPickerFrame, PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), }) 
	new("UIStroke", { Parent = ColorMap, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, }) 
	new("UIStroke", { Parent = ColorMarker, BorderStrokePosition = Enum.BorderStrokePosition.Center, LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 1.25, }) 
	new("UIStroke", { Parent = HueBar, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, }) 
	new("UIStroke", { Parent = HueMarker, LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 2, }) 
	new("UIStroke", { Parent = HueMarker, BorderStrokePosition = Enum.BorderStrokePosition.Inner, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 1.9, }) 
	new("UIStroke", { Parent = AlphaBar, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, }) 
	new("UIGradient", { Parent = AlphaFill, Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }, }) 
	new("UIStroke", { Parent = AlphaMarker, LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 2, }) 
	new("UIStroke", { Parent = AlphaMarker, BorderStrokePosition = Enum.BorderStrokePosition.Inner, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 1.9, }) 
	new("UIStroke", { Parent = CopyButton, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, }) 
	new("UIPadding", { Parent = CopyButton, PaddingBottom = UDim.new(0, 1), PaddingRight = UDim.new(0, 1), })

	ColorPickerFrame.MouseEnter:Connect(function()
		for _, w in next, lib['BROWEN😂😂'] do
			w.i.Draggable = false;
			print(w.Name)
		end
	end)

	ColorPickerFrame.MouseLeave:Connect(function()
		for _, w in next, lib['BROWEN😂😂'] do
			w.i.Draggable = true;
			print('made undrag')
		end
	end)

	if not lib['ahahahagvafdadadf'] then
		lib['ahahahagvafdadadf'] = {};
	end
	table.insert(lib['ahahahagvafdadadf'], CopyButton)

	CopyButton.Activated:Connect(function()
		if lib['Pull up with a Tech, bitch I never lack, ooh / Hunnid on my neck, hunnid on the dash, ooh / They all hit my line for a follow back, ooh / Skrrt skrrt skrrt skrrt in the Cadillac, ooh / Puffing on the green, bitch I feel like yoda'] ~= nil then
			ElementData:Set(lib['Pull up with a Tech, bitch I never lack, ooh / Hunnid on my neck, hunnid on the dash, ooh / They all hit my line for a follow back, ooh / Skrrt skrrt skrrt skrrt in the Cadillac, ooh / Puffing on the green, bitch I feel like yoda'].v, lib['Pull up with a Tech, bitch I never lack, ooh / Hunnid on my neck, hunnid on the dash, ooh / They all hit my line for a follow back, ooh / Skrrt skrrt skrrt skrrt in the Cadillac, ooh / Puffing on the green, bitch I feel like yoda'].a)

			for _, ioioioi in lib['ahahahagvafdadadf'] do
				ioioioi.Text = 'C'
				lib['Pull up with a Tech, bitch I never lack, ooh / Hunnid on my neck, hunnid on the dash, ooh / They all hit my line for a follow back, ooh / Skrrt skrrt skrrt skrrt in the Cadillac, ooh / Puffing on the green, bitch I feel like yoda'] = nil
			end

			return
		end
		lib['Pull up with a Tech, bitch I never lack, ooh / Hunnid on my neck, hunnid on the dash, ooh / They all hit my line for a follow back, ooh / Skrrt skrrt skrrt skrrt in the Cadillac, ooh / Puffing on the green, bitch I feel like yoda'] = {
			v = ElementData.val;
			a = ElementData.alpha;
		};

		for _, ioioioi in lib['ahahahagvafdadadf'] do
			ioioioi.Text = 'P'
		end
	end)

	local Editing = false;

	local AlphaBarValue = 1;
	local HueBarValue = 0;
	local ColorMapValue = { X = 0; Y = 0; }

	local function RepositionColorPicker()
		ColorPickerFrame.Position = UDim2.fromOffset(
			ElementButton.AbsolutePosition.X + 2,
			ElementButton.AbsolutePosition.Y + (ElementButton.AbsoluteSize.Y) + 8
		)
	end

	local function GetKeypointValue(sequence: ColorSequence, time: number)
		if time == 0 then
			return sequence.Keypoints[1].Value
		elseif time == 1 then
			return sequence.Keypoints[#sequence.Keypoints].Value
		end

		for i = 1, #sequence.Keypoints - 1 do
			local ThisKeypoint = sequence.Keypoints[i]
			local NextKeypoint = sequence.Keypoints[i + 1]
			if time >= ThisKeypoint.Time and time < NextKeypoint.Time then
				local Alpha = (time - ThisKeypoint.Time) / (NextKeypoint.Time - ThisKeypoint.Time)
				return Color3.new(
					(NextKeypoint.Value.R - ThisKeypoint.Value.R) * Alpha + ThisKeypoint.Value.R,
					(NextKeypoint.Value.G - ThisKeypoint.Value.G) * Alpha + ThisKeypoint.Value.G,
					(NextKeypoint.Value.B - ThisKeypoint.Value.B) * Alpha + ThisKeypoint.Value.B
				)
			end
		end
	end

	local function StringToColor(String : string)
		local ColorData = String:split(',')
		local ColorType = nil;

		if #ColorData == 1 then ColorType = 'Hex' end
		if #ColorData <= 3 then ColorType = 'HSV' end
		if #ColorData >= 4 then ColorType = 'RGBA' end

		for Index, value in ColorData do
			ColorData[Index] = tonumber(value)
		end

		if ColorType == 'Hex' then
			return Color3.fromHex(String), ColorData[2]
		end

		if ColorType == 'RGBA' then
			return Color3.fromRGB(ColorData[1], ColorData[2], ColorData[3]), ColorData[4]
		end
	end

	local function ColorToString(Color : Color3) : string
		local Split = tostring(ElementData.alpha):split('.')
		local Number = Split[1]
		local Decimal = Split[2]

		return string.gsub('%s, %s, %s, %s', 
			math.floor(ElementData.val.R*255),
			math.floor(ElementData.val.G*255),
			math.floor(ElementData.val.B*255),
			`{Number}{Decimal and `.{Decimal:sub(1,3)}` or ''}`
		)
	end

	local function UpdateColor(HSV, Alpha)
		local PackedHSV = { HSV:ToHSV() }

		Alpha = math.clamp(Alpha or 0, 0, 1)

		ElementData.val = HSV or ElementData.val
		ElementData.alpha = Alpha or ElementData.alpha

		AlphaBarValue = (AlphaMarker.Position.X.Scale);
		HueBarValue = HueMarker.Position.Y.Scale;
		ColorMapValue = {
			X = ColorMarker.Position.X.Scale;
			Y = ColorMarker.Position.Y.Scale;
		}

		ElementButton.BackgroundColor3 = ElementData.val
		ElementButton.BackgroundTransparency = (1-ElementData.alpha)

		PreviewButton.BackgroundColor3 = ElementData.val
		PreviewButton.BackgroundTransparency = (1-ElementData.alpha)

		AlphaFill.BackgroundColor3 = ElementData.val

		local Split = tostring(Alpha):split('.')
		local Number = Split[1]
		local Decimal = Split[2] or ''

		local RGBA = {
			[1] = HSV.R;
			[2] = HSV.G;
			[3] = HSV.B;
		}

		ElementData.call(ElementData.val, ElementData.alpha)
	end

	local function UpdateColorMap()
		local AbsPos = ColorMap.AbsolutePosition
		local AbsSize = ColorMap.AbsoluteSize

		local RelativeMouseX = math.clamp(((Mouse.X - AbsPos.X) / AbsSize.X), 0, 1)
		local RelativeMouseY = math.clamp(((Mouse.Y - AbsPos.Y) / AbsSize.Y), 0, 1)

		game:GetService('TweenService'):Create(
			ColorMarker,
			TweenInfo.new(.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out) ,
			{ 
				Position = UDim2.fromScale(RelativeMouseX, RelativeMouseY), 
				AnchorPoint = Vector2.new(RelativeMouseX, RelativeMouseY) 
			}
		):Play();

		local Color = {GetKeypointValue(SaturationGradient.Color, RelativeMouseX):ToHSV()}
		local value = {GetKeypointValue(ValueGradient.Color, RelativeMouseY):ToHSV()}

		ColorMapValue.X = RelativeMouseX
		ColorMapValue.Y = RelativeMouseY

		UpdateColor(Color3.fromHSV(Color[1], Color[2], value[3]), AlphaBarValue)
	end

	local function UpdateMarkers()
		local ColorHSV = { ElementData.val:ToHSV() }

		ColorMarker.Position = UDim2.fromScale(ColorHSV[2], 1-ColorHSV[3])
		ColorMarker.AnchorPoint = Vector2.new(ColorHSV[2], 1-ColorHSV[3])
		SaturationGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,1));
			ColorSequenceKeypoint.new(1,Color3.fromHSV(ColorHSV[1], 1, 1));
		})

		HueMarker.Position = UDim2.fromScale(0.5, (ColorHSV[1]))
		HueMarker.AnchorPoint = Vector2.new(0.5, (ColorHSV[1]))

		AlphaMarker.Position = UDim2.fromScale((ElementData.alpha))
		AlphaMarker.AnchorPoint = Vector2.new((ElementData.alpha))
	end

	local function UpdateHueBar()
		local AbsPos = HueBar.AbsolutePosition
		local AbsSize = HueBar.AbsoluteSize

		local RelativeMouseX = math.clamp(((Mouse.X - AbsPos.X) / AbsSize.X), 0, 1)
		local RelativeMouseY = math.clamp(((Mouse.Y - AbsPos.Y) / AbsSize.Y), 0, 1)

		game:GetService('TweenService'):Create(
			HueMarker, 
			TweenInfo.new(.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
			{ Position = UDim2.fromScale(0.5, RelativeMouseY), AnchorPoint = Vector2.new(0.5, RelativeMouseY) }
		):Play();

		local Color = GetKeypointValue(HueGradient.Color, RelativeMouseY)

		SaturationGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,1));
			ColorSequenceKeypoint.new(1, Color);
		})

		HueBarValue = RelativeMouseY

		local Color = {GetKeypointValue(SaturationGradient.Color, ColorMapValue.X):ToHSV()}
		local value = {GetKeypointValue(ValueGradient.Color, ColorMapValue.Y):ToHSV()}

		UpdateColor(Color3.fromHSV(Color[1], Color[2], value[3]), AlphaBarValue)
	end

	local function UpdateAlphaBar()
		local AbsPos = AlphaBar.AbsolutePosition
		local AbsSize = AlphaBar.AbsoluteSize

		local RelativeMouseX = math.clamp(((Mouse.X - AbsPos.X) / AbsSize.X), 0, 1)
		local RelativeMouseY = math.clamp(((Mouse.Y - AbsPos.Y) / AbsSize.Y), 0, 1)

		game:GetService('TweenService'):Create(
			AlphaMarker,
			TweenInfo.new(.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
			{ Position = UDim2.fromScale(RelativeMouseX, .5), AnchorPoint = Vector2.new(RelativeMouseX, .5) }
		):Play();

		AlphaBarValue = RelativeMouseX

		local Color = {GetKeypointValue(SaturationGradient.Color, ColorMapValue.X):ToHSV()}
		local value = {GetKeypointValue(ValueGradient.Color, ColorMapValue.Y):ToHSV()}

		UpdateColor(Color3.fromHSV(Color[1], Color[2], value[3]), AlphaBarValue)
	end

	function ElementData:Set(NewValue : any?, Alpha : number)
		local IsColor = typeof(NewValue) == 'Color3' and true or false

		if IsColor then
			UpdateColor(NewValue, Alpha)
			UpdateMarkers()
		elseif not IsColor and typeof(NewValue) == 'string' then
			local Converted = StringToColor(NewValue);
			UpdateColor(Color3.fromRGB(Converted[1], Converted[2], Converted[3]), Converted[4])
			UpdateMarkers()
		end
	end

	ElementButton:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
		RepositionColorPicker()
	end)

	ElementButton.Activated:Connect(function()
		ColorPickerFrame.Visible = not ColorPickerFrame.Visible
		ElementData.Dropped = ColorPickerFrame.Visible

		RepositionColorPicker()
	end)

	game:GetService('UserInputService').InputBegan:Connect(function(Input)
		if ((Input.UserInputType ==Enum.UserInputType.MouseButton1) or (Input.UserInputType ==Enum.UserInputType.Touch)) then
			if AlphaBar.GuiState ==Enum.GuiState.Press then
				Editing = "AlphaBar"
				UpdateAlphaBar()
			end

			if HueBar.GuiState ==Enum.GuiState.Press then
				Editing = "HueBar"
				UpdateHueBar()
			end

			if ColorMap.GuiState ==Enum.GuiState.Press then
				Editing = 'ColorMap'
				UpdateColorMap()
			end
		end
	end)

	game:GetService('UserInputService').InputEnded:Connect(function(Input)
		if ((Input.UserInputType ==Enum.UserInputType.MouseButton1) or (Input.UserInputType ==Enum.UserInputType.Touch)) then
			Editing = false;

			ElementData.Draggable = false;
		end
	end)

	local Connections = {
		ColorMap = UpdateColorMap;
		AlphaBar = UpdateAlphaBar;
		HueBar = UpdateHueBar;
	}

	game:GetService('UserInputService').InputChanged:Connect(function(Input)
		if Input.UserInputType ==Enum.UserInputType.MouseMovement and Editing then
			Connections[Editing]();
		end
	end)

	game:GetService('UserInputService').TouchMoved:Connect(function(Input)
		if Input.UserInputType ==Enum.UserInputType.Touch and Editing then
			Connections[Editing]();
		end
	end)

	ElementData:Set(ElementData.val, ElementData.alpha)
	RepositionColorPicker();
end

function lib.elements:newtoggle(...)
	local d = lib:overwrite({doomdtw_is_so_cute = self.doomdtw_is_so_cute;}, ... or {})local e = self:baee(d);return e:addtog(d);
end

function lib.elements:newcolor(...)
	local d = lib:overwrite({doomdtw_is_so_cute = self.doomdtw_is_so_cute;}, ... or {})local e = self:baee(d);return e:addtscolor(d);
end

function lib.elements:newkeybind(...)
	local d = lib:overwrite({doomdtw_is_so_cute = self.doomdtw_is_so_cute;}, ... or {})local e = self:baee(d);return e:addkiki(d);
end

function lib.elements:newslider(...)
	local data = lib:overwrite({
		text = 'browen';
		val = 0;
		min = 20;
		max = 100;
		prefix = '';
		suffix = '';
		call = print;
		axis = 'x';
	}, ... or {})

	local base = self:baee(...)

	local hitbox = new("TextButton", { Parent = base.c3; Name = "Sliderbutton"; TextTransparency = 1; AutoButtonColor = false; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.new(1, 0, 0, 6); TextColor3 = Color3.fromRGB(0, 0, 0); TextSize = 14; }) :: TextButton 
	local fill = new("Frame", { Parent = hitbox; Name = "Fill"; BackgroundColor3 = Color3.fromRGB(255, 0, 245); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.fromScale(0.5, 1); }) 
	new("UIStroke", { Parent = hitbox; ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) 

	local mouse = game.Players.LocalPlayer:GetMouse();
	local down = nil;
	local val = nil;

	local function ie(Input : InputObject, GPE)
		if Input.UserInputState == Enum.UserInputState.End then
			down = nil
		else
			down = (down and (down) or hitbox.GuiState == Enum.GuiState.Press)
		end

		if down and lib:validinput(Input) then
			local minb = hitbox.AbsolutePosition
			local maxb = (minb + hitbox.AbsoluteSize);
			local clamp = Vector2.new(math.clamp(mouse.X, minb.X, maxb.X),math.clamp(mouse.Y, minb.Y, maxb.Y))
			local rel = ((clamp - minb) / hitbox.AbsoluteSize)
			local frac = (data.axis == 'x') and rel.X or rel.Y
			local value = data.min + (data.max - data.min) * frac
			value = math.clamp(value, data.min, data.max)
			data:set(value)
		end
	end

	function data:set(v)
		data.val = v;

		if val then val.Text = `{data.prefix}{data.val}{data.suffix}` end

		fill.Size = UDim2.fromScale(
			data.axis == 'x' and ((data.val - data.min) / (data.max - data.min)) or 1,
			data.axis == 'x' and 1 or ((data.val - data.min) / (data.max - data.min))
		)
		data.call(v)
	end

	game:GetService('UserInputService').InputBegan:Connect(ie);
	game:GetService('UserInputService').InputEnded:Connect(ie);
	game:GetService('UserInputService').InputChanged:Connect(ie);

	return data
end

function lib.elements:newdropdown(...)
	local data = lib:overwrite({
		doomdtw_is_so_cute = self.doomdtw_is_so_cute;
		dropped = false;
		multi = true;
		val = {};
		size = nil;
		--list =  {
		--	'Fuck';
		--	'Joseph';
		--	'Davinci';
		--	'For';
		--	'Scamming';
		--	'Me';
		--	'Out';
		--	'Of';
		--	'$150';
		--	'For';
		--	'A';
		--	'Dead';
		--	'Artists';
		--	'Song';
		--	'Go Harass Him at @josephdavinci on ig';
		--	'and tell him to send me popstar 2.wav';
		--};
		list = {};
		call = print;
	}, ... or {})

	local e = self:baee(data);
	local d=...

	local dropdown = new("Frame", { Parent = e.c3; Name = "dropdown"; AutomaticSize =Enum.AutomaticSize.Y; BackgroundColor3 = Color3.fromRGB(20, 20, 20); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.new(1, 0, 0, 6); }) :: Frame 
	local hitbox = new("TextButton", { Parent = dropdown; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.new(1, 0, 0, 16); Text = ""; TextColor3 = Color3.fromRGB(200, 200, 200); TextSize = 14; }) :: TextButton 
	local hitboxlabel = new("TextLabel", { Parent = hitbox; AutomaticSize =Enum.AutomaticSize.X; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.fromScale(0, 1); Text = "dropdown"; TextColor3 = Color3.fromRGB(200, 200, 200); TextSize = 14; }) :: TextLabel 
	local optionlist = new("Frame", { Parent = lib.ui; Name = "ListFrame"; Visible = false; AutomaticSize =Enum.AutomaticSize.Y; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.fromOffset(161, 0); }) :: Frame 
	local optionbutton = new("TextButton", { Parent = optionlist; Visible = false; TextXAlignment = Enum.TextXAlignment.Left, Name = "optionbutton"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.new(1, 0, 0, 16); Text = ""; TextColor3 = Color3.fromRGB(0, 0, 0); TextSize = 14; }) :: TextButton 
	local dropdownicon = new("ImageLabel", { Parent = hitbox; AnchorPoint = Vector2.new(1, 0.5); BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Image = "rbxassetid://86464972789532"; ImageColor3 = Color3.fromRGB(152, 152, 152); Position = UDim2.fromScale(1, 0.5); Size = UDim2.fromOffset(6, 6); }) 
	new("UIListLayout", { Parent = dropdown; Padding =UDim.new(0, 5); SortOrder = Enum.SortOrder.LayoutOrder; }) 
	new("UIListLayout", { Parent = optionlist; Padding =UDim.new(0, 1); SortOrder = Enum.SortOrder.LayoutOrder; }) 
	new("UIGradient", { Parent = hitbox; Color =ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)), ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18)) }; Rotation = 90; }) 
	new("UIPadding", { Parent = hitbox; PaddingLeft =UDim.new(0, 4); PaddingRight =UDim.new(0, 4); }) 
	new("UIPadding", { Parent = optionbutton; PaddingLeft =UDim.new(0, 4); PaddingRight =UDim.new(0, 4); }) 
	new("UIStroke", { Parent = hitbox; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; }) 
	new("UIStroke", { Parent = optionbutton; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; Enabled = false; }) 
	new("UIStroke", { Parent = optionlist; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; }) 

	data['https://www.youtube.com/watch?v=8TNMsUnIXAE'] = function()
		optionlist.Size = UDim2.fromOffset(hitbox.AbsoluteSize.X, 0)
		optionlist.Position = UDim2.fromOffset(hitbox.AbsolutePosition.X, (hitbox.AbsolutePosition.Y + hitbox.AbsoluteSize.Y))
	end

	hitbox:GetPropertyChangedSignal('AbsoluteSize'):Connect(data['https://www.youtube.com/watch?v=8TNMsUnIXAE']);
	hitbox:GetPropertyChangedSignal('AbsolutePosition'):Connect(data['https://www.youtube.com/watch?v=8TNMsUnIXAE']);

	optionlist.Size = UDim2.fromOffset(data.size, 0);

	for i,v in next, data.list do
		local OwO= optionbutton:Clone();
		OwO.Parent = optionlist;
		OwO.Text = v;
		OwO.Visible = true;
		OwO.TextColor3 = lib.theme.t2

		if table.find(data.val, v) then
			OwO.TextColor3 = lib.theme.accent;
		end

		OwO.Activated:Connect(function()
			if not data.multi then
				for _, o in next, optionlist:GetChildren() do
					if o:IsA('TextButton') then
						o.TextColor3 = lib.theme.t2
						data.val = {};
					end
				end
			end

			if table.find(data.val, v) then
				table.remove(data.val, table.find(data.val, v))
				OwO.TextColor3 = lib.theme.t2

				data:set(data.val);
				return
			end

			table.insert(data.val, v)
			OwO.TextColor3 = lib.theme.accent;

			data:set(data.val);
		end)
	end

	function data:set(v)
		data.call(v);
		hitboxlabel.Text = #data.val > 0 and table.concat(v, ', ') or 'none'
	end

	hitbox.Activated:Connect(function()
		optionlist.Visible = not optionlist.Visible
		dropdownicon.Rotation = optionlist.Visible and 180 or 0
	end)

	return data

end

function lib:win(name, ...)
	local window = lib:overwrite({
		size = UDim2.fromOffset(800, 540);
		position = UDim2.fromScale(.5, .5);
		anchor = Vector2.new(.5, .5);
		title = '';
		logo = '';
		tabs = {};
		links = {};
		active = true;
	}, ... or {})

	local windowframe = new("Frame", { Parent = lib.ui; Draggable = true; Selectable = true; Active = true; Name = "WindowFrame"; BackgroundColor3 = Color3.fromRGB(13, 13, 13); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.fromScale(0.33789411187171936, 0.28999999165534973); Size = UDim2.fromOffset(621, 400); }) :: Frame 
	local topbar = new("Frame", { Parent = windowframe; Name = "Topbar"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.fromOffset(-10, 0); Size = UDim2.new(1, 20, 0, 30); }) :: Frame 
	local titlelabel = new("TextLabel", { Parent = topbar; Name = "TitleLabel"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.fromScale(1, 1); Text = window.title; TextColor3 = Color3.fromRGB(255, 255, 255); TextSize = 14; TextXAlignment = Enum.TextXAlignment.Left; }) :: TextLabel 
	local content = new("Frame", { Parent = windowframe; Name = "Content"; AnchorPoint = Vector2.new(0, 1); BackgroundColor3 = Color3.fromRGB(18, 18, 18); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.fromScale(0, 1); Size = UDim2.new(1, 0, 1, -30); }) :: Frame 
	local sidebar = new("Frame", { Parent = content; Name = "Sidebar"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.new(0, 130, 1, 0); }) :: Frame 
	local logomask = new("Frame", { Parent = sidebar; Name = "LogoMask"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; ClipsDescendants = true; Size = UDim2.new(1, 0, 0, 80); }) :: Frame 
	local logolabel = new("ImageLabel", { Parent = logomask; Name = "LogoLabel"; AnchorPoint = Vector2.new(0.5, 0.5); BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Image = window.logo; Position = UDim2.fromScale(0.5, 0.5); Size = UDim2.fromScale(1.5, 1.5); }) :: ImageLabel 
	local tabbuttons = new("Frame", { Parent = sidebar; Name = "TabButtons"; AnchorPoint = Vector2.new(0, 1); BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.fromScale(0, 1); Size = UDim2.new(1, 0, 1, -86); }) :: Frame 
	local tabcontainer = new("Frame", { Parent = content; Name = "TabContainer"; AnchorPoint = Vector2.new(1, 0); BackgroundColor3 = Color3.fromRGB(18, 18, 18); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.fromScale(1, 0); Size = UDim2.new(1, -136, 1, 0); }) :: Frame 
	new("UIGradient", { Parent = topbar; Color =ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 26, 26)), ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 13, 13)) }; Rotation = 90; }) 
	new("UIPadding", { Parent = titlelabel; PaddingLeft =UDim.new(0, 10); }) 
	new("UIStroke", { Parent = windowframe; BorderStrokePosition = Enum.BorderStrokePosition.Inner; }) 
	new("UIStroke", { Parent = content; }) 
	new("UIAspectRatioConstraint", { Parent = logolabel; }) 
	new("UIPadding", { Parent = sidebar; }) 
	new("UIListLayout", { Parent = tabbuttons; Padding =UDim.new(0, 3); SortOrder = Enum.SortOrder.LayoutOrder; }) 
	new("UIPadding", { Parent = content; PaddingBottom =UDim.new(0, 6); PaddingLeft =UDim.new(0, 6); PaddingRight =UDim.new(0, 6); PaddingTop =UDim.new(0, 6); }) 
	new("UIStroke", { Parent = tabcontainer; }) 
	new("UIPadding", { Parent = windowframe; PaddingBottom =UDim.new(0, 10); PaddingLeft =UDim.new(0, 10); PaddingRight =UDim.new(0, 10); }) 

	function window:toggle(b : boolean)
		if (b == nil or typeof(b) ~= 'boolean') then b = not window.active end;
		window.active = b;
		windowframe.Visible = window.active;
	end

	function window:exit()
		window.frame:Destroy();
		lib:closetasks(window.links);
	end

	function window:update(...)
		local window = lib:overwrite(window, ... or {})

		windowframe.Size = window.size;
		windowframe.Position = window.position;
		windowframe.AnchorPoint = window.anchor;
		logolabel.Image = window.logo;
		titlelabel.Text = window.title;
	end

	function window:tab(name, ...)
		local tab = lib:overwrite({ 
			name = name or 'tab';
			groups = {};
			links = {};
			active = false;
		}, ... or {});

		local tabframe = new("Frame", { Parent = tabcontainer; Name = "tabframe"; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.fromScale(1, 1); }) :: Frame 
		local leftc = new("Frame", { Parent = tabframe; Name = "leftc"; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.fromOffset(100, 100); }) :: Frame 
		local rightc = new("Frame", { Parent = tabframe; Name = "rightc"; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.fromOffset(100, 100); }) :: Frame 
		new("UIListLayout", { Parent = tabframe; FillDirection =Enum.FillDirection.Horizontal; HorizontalFlex = Enum.UIFlexAlignment.Fill; Padding =UDim.new(0, 9); SortOrder = Enum.SortOrder.LayoutOrder; VerticalFlex = Enum.UIFlexAlignment.Fill; }) 
		new("UIPadding", { Parent = tabframe; PaddingBottom =UDim.new(0, 5); PaddingLeft =UDim.new(0, 5); PaddingRight =UDim.new(0, 5); PaddingTop =UDim.new(0, 5); }) 
		new("UIListLayout", { Parent = leftc; HorizontalFlex = Enum.UIFlexAlignment.Fill; Padding =UDim.new(0, 10); SortOrder = Enum.SortOrder.LayoutOrder; VerticalFlex = Enum.UIFlexAlignment.Fill; }) 
		new("UIListLayout", { Parent = rightc; HorizontalFlex = Enum.UIFlexAlignment.Fill; Padding =UDim.new(0, 10); SortOrder = Enum.SortOrder.LayoutOrder; VerticalFlex = Enum.UIFlexAlignment.Fill; }) 



		local tabbutton = new("TextButton", { Parent = tabbuttons; Name = "tabbutton"; AutoButtonColor = false; BackgroundColor3 = Color3.fromRGB(15, 15, 15); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Size = UDim2.new(1, 0, 0, 30); Text = tab.name; TextColor3 = Color3.fromRGB(255, 255, 255); TextSize = 14; TextXAlignment = Enum.TextXAlignment.Left; }) :: TextButton 
		local accent = new("Frame", { Parent = tabbutton; Name = "accent"; AnchorPoint = Vector2.new(0, 0.5); BackgroundColor3 = Color3.fromRGB(255, 0, 245); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.new(0, -9, 0.5, 0); Size = UDim2.new(0, 2, 1, -2); Visible = false; }) 
		new("UIStroke", { Parent = tabbutton; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; BorderStrokePosition = Enum.BorderStrokePosition.Inner; }) 
		new("UIPadding", { Parent = tabbutton; PaddingLeft =UDim.new(0, 10); }) 

		function tab:toggle(b : boolean)
			if (b == nil or typeof(b) ~= 'boolean') then b = not tab.active end
			if b then
				for _, t in next, window.tabs do
					if t ~= tab then
						t:toggle(false)
					end
				end
			end

			tab.active = b;
			tabframe.Visible = tab.active;
			accent.Visible = tab.active;
			tabbutton.BackgroundColor3 = tab.active and Color3.fromRGB(23,23,23) or Color3.fromRGB(15,15,15);
		end

		function tab:remove()
			lib:closetasks(tab.links);
			tabbutton:Destroy();
			tabframe:Destroy();
			tab=nil;
		end

		function tab:group(name, ...)
			local group = lib:overwrite({
				name = name or 'group';
				side = 'left';
				size = 1;
				elements = {};
				links = {};
				active = true;
			}, ... or {});

			local groupframe = new("Frame", { Parent = group.side == 'left' and leftc or rightc; Name = "groupframe"; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Size = UDim2.new(1, group.size); }) :: Frame 
			local titlecard = new("Frame", { Parent = groupframe; Name = "titlecard"; AutomaticSize =Enum.AutomaticSize.X; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; Position = UDim2.fromOffset(8, -1); Size = UDim2.fromOffset(0, 2); }) :: Frame 
			local titleshadow = new("TextLabel", { Parent = titlecard; Name = "titleshadow"; AutomaticSize =Enum.AutomaticSize.X; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Position = UDim2.fromOffset(1, -5); Size = UDim2.fromOffset(0, 6); Text = group.name; TextColor3 = Color3.fromRGB(0, 0, 0); TextSize = 14; }) :: TextLabel 
			local titlelabel = new("TextLabel", { Parent = titleshadow; Name = "titlelabel"; AutomaticSize =Enum.AutomaticSize.X; BackgroundColor3 = Color3.fromRGB(18, 18, 18); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal); Position = UDim2.fromOffset(-1, -1); Size = UDim2.fromOffset(0, 5); Text = group.name; TextColor3 = Color3.fromRGB(255, 255, 255); TextSize = 14; }) :: TextLabel 
			local groupcontent = new("ScrollingFrame", { Parent = groupframe; Name = "groupcontent"; Active = true; AutomaticCanvasSize =Enum.AutomaticSize.Y; BackgroundColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; BorderColor3 = Color3.fromRGB(0, 0, 0); BorderSizePixel = 0; BottomImage = "rbxassetid://132155326"; CanvasSize = UDim2.fromScale(0, 0); MidImage = "rbxassetid://132155326"; ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0); ScrollBarThickness = 2; Size = UDim2.fromScale(1, 1); TopImage = "rbxassetid://132155326"; }) :: ScrollingFrame 
			new("UIStroke", { Parent = groupframe; BorderStrokePosition = Enum.BorderStrokePosition.Inner; }) 
			new("UIStroke", { Parent = groupframe; Color = Color3.fromRGB(28, 28, 28); }) 
			new("UIPadding", { Parent = titleshadow; }) 
			new("UIPadding", { Parent = titlelabel; PaddingLeft =UDim.new(0, 3); PaddingRight =UDim.new(0, 3); }) 
			new("UIListLayout", { Parent = groupcontent; Padding =UDim.new(0, 8); SortOrder = Enum.SortOrder.LayoutOrder; }) 
			new("UIPadding", { Parent = groupcontent; PaddingBottom =UDim.new(0, 10); PaddingLeft =UDim.new(0, 26); PaddingRight =UDim.new(0, 30); PaddingTop =UDim.new(0, 12); }) 

			function group:toggle(b : boolean)
				if (b == nil or typeof(b) ~= 'boolean') then b = not tab.active end

				tab.active = b;
				groupframe.Visible = tab.active;
			end

			function group:remove()
				groupframe:Destroy();
				lib:closetasks(group.links);
				group = nil;
			end

			group.doomdtw_is_so_cute = groupcontent
			setmetatable(group, lib.elements);
			table.insert(group, tab.groups);
			return group
		end

		if #window.tabs == 0 then tab:toggle(true); else tab:toggle(false) end
		table.insert(window.tabs, tab)
		tabbutton.Activated:Connect(tab['toggle']);
		return tab
	end

	window.i = windowframe
	table.insert(lib['BROWEN😂😂'], window)
	return window
end

return lib