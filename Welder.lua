if getgenv().mentalsgui then
    getgenv().mentalsgui:Destroy()
end
local localplr = game:GetService("Players").LocalPlayer
local mouse = localplr:GetMouse()
local StarterGui = game:GetService("StarterGui")
local conn = {}
local sgui = Instance.new("ScreenGui")
sgui.IgnoreGuiInset = true
getgenv().mentalsgui = sgui
local hiddenUI = (get_hidden_gui and get_hidden_gui()) or (gethui and gethui()) or game.CoreGui or error("your executor sucks")
sgui.Parent = hiddenUI
local mainColor = Color3.fromRGB(100, 100, 100)
mainBorderColor = Color3.new(1,1,1)
function darken(amount, color, mult)
    if color == nil then color = mainColor end
    if mult == nil then mult = 20 end
    return Color3.fromRGB(color.R*255 - amount*mult, color.G*255 - amount*mult, color.B*255 - amount*mult)
end
function Create(ClassName, Properties)
    local thing = Instance.new(ClassName)
    for i,v in pairs(Properties) do
        thing[i] = v
    end
    local hasBorderColor3 = pcall(function()
        return thing.BorderColor3
    end)
    if hasBorderColor3 then
        thing.BorderColor3 = mainBorderColor
    end
    return thing
end
local mainframe = Create("Frame", {
    Size = UDim2.new(0.75, 0, 0.375, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = darken(0),
    Parent = sgui
})
Create("UIAspectRatioConstraint", {
    AspectRatio = 1.75,
	DominantAxis = Enum.DominantAxis.Height,
    Parent = mainframe
})
Create("UIDragDetector", {
	Parent = mainframe
})
local title = Create("TextLabel", {
    Text = "Welder\nBy AreYouMental110",
    TextScaled = true,
    Size = UDim2.new(1-(0.2/1.75), 0, 0.2, 0),
    TextColor3 = mainBorderColor,
    BackgroundColor3 = darken(0),
    Parent = mainframe
})
local CloseButton = Create("TextButton", {
	Size = UDim2.new(0.2/1.75, 0, 0.2, 0),
	Position = UDim2.new(1-(0.2/1.75), 0, 0, 0),
	TextColor3 = Color3.new(1, 0, 0),
	BackgroundColor3 = darken(-1),
	TextStrokeTransparency = 0,
	Text = "X",
	TextScaled = true,
	Parent = mainframe
})
local bindfuncClose = Instance.new("BindableFunction")
bindfuncClose.OnInvoke = function()
	sgui:Destroy()
end
CloseButton.MouseButton1Click:Connect(function()
	StarterGui:SetCore("SendNotification",{Title="Notification",Text="Close out of the script?",Duration=5,Callback=bindfuncClose,Button1="Yes",Button2="No"})
end)
local TabButtonHolder = Create("ScrollingFrame", {
	BackgroundColor3 = darken(0),
	Size = UDim2.new(0.3, 0, 0.8, -1),
	Position = UDim2.new(0, 0, 0.2, 1),
	Parent = mainframe
})

local function createListLayout(tab)
	Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tab
	})
	local layoutn = 0
	tab.ChildAdded:Connect(function(c)
		if c:IsA("GuiObject") then
			layoutn += 1
			c.LayoutOrder = layoutn
		end
	end)
end

createListLayout(TabButtonHolder)

local function closeOtherWindow() end
local function CreateTab(name, visible)
	local TabWindow = Create("ScrollingFrame", {
		BackgroundColor3 = darken(0),
		Size = UDim2.new(0.7, 0, 0.8, -1),
		Position = UDim2.new(0.3, 0, 0.2, 1),
		CanvasSize = UDim2.new(0, 0, 12, 0),
		Visible = visible or false,
		Parent = mainframe
	})
	local TabButton = Create("TextButton", {
		Size = UDim2.new(1, -12, 0.075, 0),
		TextColor3 = mainBorderColor,
		BackgroundColor3 = darken(-1),
		Text = name,
		TextScaled = true,
		Parent = TabButtonHolder
	})
	local function onMouseButton1Click()
		closeOtherWindow(TabWindow)
		closeOtherWindow = function(CurrentTabWindow)
			if CurrentTabWindow ~= TabWindow then
				TabWindow.Visible = false
				TabButton.BackgroundColor3 = darken(-1)
			end
		end
		TabWindow.Visible = true
		TabButton.BackgroundColor3 = darken(1)
	end
	TabButton.MouseButton1Click:Connect(onMouseButton1Click)
	if visible then
		onMouseButton1Click()
	end
	return TabWindow, TabButton
end

local WeldingTab = CreateTab("Welding", true)
local CustomWeldCode = CreateTab("Custom Weld Code")
CustomWeldSettings = CreateTab("Custom Weld Settings")

createListLayout(WeldingTab)
createListLayout(CustomWeldSettings)

local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RenderStepped = RunService.RenderStepped

CurrentWeld = nil
local OriginalFPDH = workspace.FallenPartsDestroyHeight

WeldOffset = CFrame.new(0, 0, 1.3)
WeldVelocity = Vector3.new(0, 0, 0)
WeldAnimID = 0

function changeWeldOffset(cfr)
	WeldOffset = cfr
end

function changeWeldVelocity(p)
	WeldVelocity = p
end

function changeWeldAnim(n)
	WeldAnimID = n
	if CurrentWeld then CurrentWeld.UpdateAnim() end
end

local ViewPartOnWeld = true

local WELD_GROUP = (function()
	local buff = buffer.create(20)

	local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local clen = #charset

	for i = 1, 20 do
		local c = string.byte(charset, math.random(1, clen))
		buffer.writeu8(buff, i - 1, c)
	end

	return buffer.tostring(buff)
end)()

pcall(function()
	PhysicsService:RegisterCollisionGroup(WELD_GROUP)
	PhysicsService:CollisionGroupSetCollidable(WELD_GROUP, WELD_GROUP, true)
end)
local LSS = false
function LowsUNCWeldTo(Part: BasePart, OverwriteVPOW): any
	if not Part.Parent then return end
	if Players:GetPlayerFromCharacter(Part.Parent :: Model) then
		local Humanoid = Part.Parent:FindFirstChildWhichIsA("Humanoid")
		if Humanoid then
			Humanoid.RequiresNeck = false
		end
	end
	local Character = localplr.Character
	if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
	local Root = Character.HumanoidRootPart.AssemblyRootPart
	local Start = CFrame.new(Root.Position)
	local Weld = {}
	local Enabled = false
	local PartJoints: {JointInstance} = {}
	local OldProps = {}
	local OldCharProps = {}
	Weld.Part = Part
	local AnimTrack = nil
	if WeldAnimID then
		local Animator = Character:FindFirstChildWhichIsA("Animator", true)
		if Animator then
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. tostring(WeldAnimID)
			AnimTrack = Animator:LoadAnimation(Animation)
			AnimTrack:Play()
		end
	end
	function Weld:Enable(toggle)
		Enabled = toggle
		if not toggle then
			for _, Joint in next, PartJoints do Joint.Enabled = true end
			for PropName, Value in next, OldProps do (Part :: any)[PropName] = Value end
			for part, props in next, OldCharProps do
				if not part or not part.Parent then continue end
				part.CollisionGroup = props.Group
				part.CanCollide = props.Collide
			end
			return
		end
		PartJoints = Part:GetJoints() :: any
		for _, PropName in next, {
			"Size",
			"CanCollide",
			"Anchored",
			"Parent",
			"CollisionGroup"
			} do
			OldProps[PropName] = (Part :: any)[PropName]
		end
		for _, p in next, Character:GetDescendants() do
			if not p:IsA("BasePart") then continue end
			OldCharProps[p] = {
				Group = p.CollisionGroup,
				Collide = p.CanCollide
			}
			p.CollisionGroup = WELD_GROUP
			p.CanCollide = true
		end
		Part.Size = Vector3.new(25, 3, 25)
		Part.Anchored = false
		Part.CanCollide = true
		Part.CollisionGroup = WELD_GROUP
		Part.Parent = workspace.Terrain
		for _, Joint in next, PartJoints do
			Joint.Enabled = false
		end
	end
	
	local ViewPartOnWeldC = ViewPartOnWeld
	if OverwriteVPOW ~= nil then
		ViewPartOnWeldC = OverwriteVPOW
	end
	local OldSubject = workspace.CurrentCamera.CameraSubject
	if ViewPartOnWeldC then
		workspace.CurrentCamera.CameraSubject = TargetPart
	end
	
	function Weld.UpdateAnim()
		local Animator = Character:FindFirstChildWhichIsA("Animator", true)
		if Animator then
			if AnimTrack then AnimTrack:Stop(); AnimTrack:Destroy() end
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. tostring(WeldAnimID)
			AnimTrack = Animator:LoadAnimation(Animation)
			AnimTrack:Play()
		end
	end
	
	local thread: thread = nil
	function Weld:Destroy()
		if ViewPartOnWeldC then
			workspace.CurrentCamera.CameraSubject = OldSubject
		end
		task.cancel(thread)
		Weld:Enable(false)
		if AnimTrack then AnimTrack:Stop(); AnimTrack:Destroy() end
	end
	thread = task.spawn(function()
		while task.wait() do
			if not Enabled then continue end

			Part.CFrame = Start
			Root.CFrame = Start * WeldOffset
			Part.AssemblyLinearVelocity = Vector3.zero
			Part.AssemblyAngularVelocity = Vector3.zero
			Root.AssemblyLinearVelocity = WeldVelocity
			Root.AssemblyAngularVelocity = Vector3.zero

			RenderStepped:Wait()

			Part.CFrame = Start
			Root.CFrame = Start * CFrame.new(0, 4, 0)
			Part.AssemblyLinearVelocity = Vector3.zero
			Part.AssemblyAngularVelocity = Vector3.zero
		end
	end)
	Weld:Enable(true)

	CurrentWeld = Weld

	return Weld
end

function WeldTo(TargetPart: BasePart, OverwriteVPOW): any
	if LSS then
		return LowsUNCWeldTo(TargetPart, OverwriteVPOW)
	end

	local Character = localplr.Character
	if not Character then return nil end
	
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Root or not Humanoid then return nil end
	
	local AnimTrack = nil
	if WeldAnimID then
		local Animator = Character:FindFirstChildWhichIsA("Animator", true)
		if Animator then
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. tostring(WeldAnimID)
			AnimTrack = Animator:LoadAnimation(Animation)
			AnimTrack:Play()
		end
	end

	local Weld = {}
	local Connection = nil
	
	Weld.Part = TargetPart
	
	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true
		end
	end
	
	Connection = RunService.Heartbeat:Connect(function()
		if not Character or not TargetPart or not Character.Parent or not TargetPart.Parent then
			if Weld.Destroy then Weld:Destroy() end
			return
		end

		Root.CFrame = TargetPart.CFrame * WeldOffset
		Root.AssemblyLinearVelocity = WeldVelocity
		Root.AssemblyAngularVelocity = Vector3.zero
		
		if sethiddenproperty then
			pcall(function()
				sethiddenproperty(Root, "PhysicsRepRootPart", TargetPart)
			end)
		end
	end)
	
	local ViewPartOnWeldC = ViewPartOnWeld
	if OverwriteVPOW ~= nil then
		ViewPartOnWeldC = OverwriteVPOW
	end
	local OldSubject = workspace.CurrentCamera.CameraSubject
	if ViewPartOnWeldC then
		workspace.CurrentCamera.CameraSubject = TargetPart
	end
	
	function Weld.UpdateAnim()
		local Animator = Character:FindFirstChildWhichIsA("Animator", true)
		if Animator then
			if AnimTrack then AnimTrack:Stop(); AnimTrack:Destroy() end
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. tostring(WeldAnimID)
			AnimTrack = Animator:LoadAnimation(Animation)
			AnimTrack:Play()
		end
	end

	function Weld:Destroy()
		if ViewPartOnWeldC then
			workspace.CurrentCamera.CameraSubject = OldSubject
		end
		
		if Connection then Connection:Disconnect() end
		if AnimTrack then AnimTrack:Stop(); AnimTrack:Destroy() end
		
		if Root then
			Root.AssemblyLinearVelocity = Vector3.zero
			Root.AssemblyAngularVelocity = Vector3.zero
		end
	end
	
	CurrentWeld = Weld

	return Weld
end

function Unweld()
	if CurrentWeld then
		CurrentWeld:Destroy()
		CurrentWeld = nil
	end
	workspace.FallenPartsDestroyHeight = OriginalFPDH
end

function getPlayerFromText(text)
	if text == "" then return false end
	text = text:lower()
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		if v ~= localplr and v.Name:lower() == text then
			return v
		end
	end
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		if v ~= localplr and v.DisplayName:lower() == text then
			return v
		end
	end
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		if v ~= localplr and string.sub(v.Name:lower(),1,#text) == text then
			return v
		end
	end
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		if v ~= localplr and string.sub(v.DisplayName:lower(),1,#text) == text then
			return v
		end
	end
	return false
end

function CreateUnweldButton(parent)
	local UnweldButton = Create("TextButton", {
		Size = UDim2.new(1, -12, 0.075/6, 0),
		TextColor3 = mainBorderColor,
		BackgroundColor3 = darken(1),
		Text = "Unweld",
		TextScaled = true,
		Parent = parent
	})
	UnweldButton.MouseButton1Click:Connect(function()
		Unweld()
	end)
	return UnweldButton
end

function CreateWeldInput(parent)
	local WeldPlayerInput = Create("TextBox", {
		Size = UDim2.new(1, -12, 0.075/6, 0),
		TextColor3 = mainBorderColor,
		BackgroundColor3 = darken(1),
		PlaceholderText = "Input a player to weld to (can shorten, not case sensitive)",
		Text = "",
		TextScaled = true,
		Parent = parent
	})
	WeldPlayerInput.FocusLost:Connect(function()
		local plr = getPlayerFromText(WeldPlayerInput.Text)
		if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			Unweld()
			WeldTo(plr.Character.HumanoidRootPart)
		end
	end)
	return WeldPlayerInput
end

Create("TextLabel", {
	Size = UDim2.new(1, -12, 0.075/6, 0),
	Position = UDim2.new(0, 0, 1.4/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(3),
	Text = "Weld method originally discovered by Failedmite and Janmandio.",
	TextScaled = true,
	Parent = WeldingTab
})

Create("TextLabel", {
	Size = UDim2.new(1, -12, 0.075/6, 0),
	Position = UDim2.new(0, 0, 1.4/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(3),
	Text = "Code taken from \"Welder V2\" Plugin in Infinite Yield",
	TextScaled = true,
	Parent = WeldingTab
})

local LSSB = Create("TextButton", {
	Size = UDim2.new(1, -6, 0.075/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	Text = "Low sUNC Support (turn on if weld doesn't work, but you wont be able to see what it looks like)",
	TextScaled = true,
	Parent = WeldingTab
})
local LSSBText = LSSB.Text
LSSB.Text = LSSBText..": OFF"
LSSB.MouseButton1Click:Connect(function()
	LSS = not LSS
	if LSS then
		LSSB.Text = LSSBText..": ON"
	else
		LSSB.Text = LSSBText..": OFF"
	end
end)

local VPOW = Create("TextButton", {
	Size = UDim2.new(1, -6, 0.075/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	Text = "View Part On Weld",
	TextScaled = true,
	Parent = WeldingTab
})
local VPOWText = VPOW.Text
VPOW.Text = VPOWText..": ON"
VPOW.MouseButton1Click:Connect(function()
	ViewPartOnWeld = not ViewPartOnWeld
	if ViewPartOnWeld then
		VPOW.Text = VPOWText..": ON"
	else
		VPOW.Text = VPOWText..": OFF"
	end
end)

CreateUnweldButton(WeldingTab)
CreateWeldInput(WeldingTab)

local AnimationIDInput = Create("TextBox", {
	Size = UDim2.new(1, -12, 0.075/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	PlaceholderText = "Input an Animation ID (optional)",
	Text = "",
	TextScaled = true,
	Parent = WeldingTab
})
AnimationIDInput.FocusLost:Connect(function()
	changeWeldAnim(tonumber(AnimationIDInput.Text))
end)

function createSlider(text, parent, m, mx, default, step, onDrag)
	step = step or 1
	local sliderframe = Create("Frame", {
		BackgroundColor3 = darken(2),
		Size = UDim2.new(1, -12, 0.075/6, 0),
		Parent = parent
	})
	local nametext = Create("TextLabel", {
		Size = UDim2.new(0.4, 0, 1, 0),
		TextScaled = true,
		TextColor3 = mainBorderColor,
		BackgroundColor3 = darken(1),
		Text = text,
		Parent = sliderframe
	})
	local slider = Create("TextButton", {
		Size = UDim2.new(.05,0,1,0),
		TextScaled = true,
		TextColor3 = mainBorderColor,
		BackgroundColor3 = darken(1),
		Text = "|",
		Parent = sliderframe
	})
	local minoffset = sliderframe.AbsoluteSize.X/2 + slider.AbsoluteSize.X/2
	local maxoffset = sliderframe.AbsoluteSize.X - slider.AbsoluteSize.X/2
	slider.Position = UDim2.new(0.5,math.clamp((-slider.AbsoluteSize.X/2 + ((default - m) / (mx - m)) * (sliderframe.AbsoluteSize.X/2)) + minoffset, minoffset + 1, maxoffset) - minoffset, 0, 0)
	local num = Create("TextBox", {
		Size = UDim2.new(.1,0,1,0),
		Position = UDim2.new(.4,0,0,0),
		TextScaled = true,
		TextColor3 = mainBorderColor,
		BackgroundColor3 = darken(1),
		PlaceholderText = tostring(default),
		Text = "",
		Parent = sliderframe
	})
	num.FocusLost:Connect(function()
		if tonumber(num.Text) then
			local number = tonumber(num.Text)
			minoffset = sliderframe.AbsoluteSize.X/2 + slider.AbsoluteSize.X/2
			maxoffset = sliderframe.AbsoluteSize.X - slider.AbsoluteSize.X/2
			slider.Position = UDim2.new(0.5,math.clamp((-slider.AbsoluteSize.X/2 + ((number - m) / (mx - m)) * (sliderframe.AbsoluteSize.X/2)) + minoffset, minoffset + 1, maxoffset) - minoffset, 0, 0)
			local tn = tostring(number)
			num.PlaceholderText = string.sub(tn, 1, (string.find(tn,"000") or string.find(tn,"999") or #tn+1)-1)
			num.Text = ""
			onDrag(number)
		end
	end)
	local hoverover = false
	slider.MouseButton1Up:Connect(function()
		hoverover = false
	end)
	table.insert(conn,game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			hoverover = false
		end
	end))
	table.insert(conn,game:GetService("UserInputService").TouchEnded:Connect(function(input)
		hoverover = false
	end))
	onDrag(default)
	local libsize = parent.AbsoluteSize
	slider.MouseButton1Down:Connect(function()
		hoverover = true
		while hoverover do
			task.wait()
			minoffset = sliderframe.AbsoluteSize.X/2 + sliderframe.AbsolutePosition.X + slider.AbsoluteSize.X/2
			maxoffset = sliderframe.AbsoluteSize.X + sliderframe.AbsolutePosition.X - slider.AbsoluteSize.X/2
			local offset = (mouse.X - minoffset)
			slider.Position = UDim2.new(0.5, math.clamp(mouse.X, minoffset + 1, maxoffset) - minoffset, 0, 0)
			local percentage = math.clamp(offset / (maxoffset - minoffset), 0, 1)
			local number = math.floor((m + (mx - m) * percentage)/step)*step
			local tn = tostring(number)
			num.PlaceholderText = string.sub(tn, 1, (string.find(tn,"000") or string.find(tn,"999") or #tn+1)-1)
			onDrag(number)
		end
	end)
	return sliderframe
end

createSlider("Weld X (left/right) Value", WeldingTab, -50, 50, 0, nil, function(n)
	local offsetComponents = {WeldOffset:GetComponents()}
	offsetComponents[1] = n
	changeWeldOffset(CFrame.new(table.unpack(offsetComponents)))
end)

createSlider("Weld Y (down/up) Value", WeldingTab, -50, 50, 0, nil, function(n)
	local offsetComponents = {WeldOffset:GetComponents()}
	offsetComponents[2] = n
	changeWeldOffset(CFrame.new(table.unpack(offsetComponents)))
end)

createSlider("Weld Z (back/forward) Value", WeldingTab, -50, 50, 0, nil, function(n)
	local offsetComponents = {WeldOffset:GetComponents()}
	offsetComponents[3] = n
	changeWeldOffset(CFrame.new(table.unpack(offsetComponents)))
end)

createSlider("Weld X Velocity (left/right) Value", WeldingTab, -50, 50, 0, nil, function(n)
	changeWeldVelocity(Vector3.new(n, WeldVelocity.Y, WeldVelocity.Z)) -- no
end)

createSlider("Weld Y Velocity (down/up) Value", WeldingTab, -50, 50, 0, nil, function(n)
	changeWeldVelocity(Vector3.new(WeldVelocity.X, n, WeldVelocity.Z)) -- nut
end)

createSlider("Weld Z Velocity (back/forward) Value", WeldingTab, -50, 50, 0, nil, function(n)
	changeWeldVelocity(Vector3.new(WeldVelocity.X, WeldVelocity.Y, n)) -- november
end)

local offsetXRot = 0
local offsetYRot = 0
local offsetZRot = 0

createSlider("Weld X Rotation Value", WeldingTab, 0, 360, 0, 5, function(n)
	offsetXRot = n
	changeWeldOffset(CFrame.new(WeldOffset.Position) * CFrame.fromOrientation(math.rad(offsetXRot), math.rad(offsetYRot), math.rad(offsetZRot)))
end)

createSlider("Weld Y Rotation Value", WeldingTab, 0, 360, 0, 5, function(n)
	offsetYRot = n
	changeWeldOffset(CFrame.new(WeldOffset.Position) * CFrame.fromOrientation(math.rad(offsetXRot), math.rad(offsetYRot), math.rad(offsetZRot)))
end)

createSlider("Weld Z Rotation Value", WeldingTab, 0, 360, 0, 5, function(n)
	offsetZRot = n
	changeWeldOffset(CFrame.new(WeldOffset.Position) * CFrame.fromOrientation(math.rad(offsetXRot), math.rad(offsetYRot), math.rad(offsetZRot)))
end)



local codebox = Create("TextBox", {
	Size = UDim2.new(1, -12, 0.25/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(2),
	PlaceholderText = "weld code here\n\nscroll down for instructions on how\nto code some",
	Text = "",
	TextSize = 16,
	MultiLine = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	ClearTextOnFocus = false,
	FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json"),
	Parent = CustomWeldCode
})

local stopfunc = function() end
local stopButton = Create("TextButton", {
	Size = UDim2.new(0.5, -6, 0.075/6, 0),
	Position = UDim2.new(0, 0, 0.25/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	Text = "Stop/Unweld",
	TextScaled = true,
	Parent = CustomWeldCode
})
stopButton.MouseButton1Click:Connect(function()
	stopfunc()
	Unweld()
	for i,v in pairs(CustomWeldSettings:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
end)

local executeButton = Create("TextButton", {
	Size = UDim2.new(0.5, -6, 0.075/6, 0),
	Position = UDim2.new(0.5, -3, 0.25/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	Text = "Execute",
	TextScaled = true,
	Parent = CustomWeldCode
})
executeButton.MouseButton1Click:Connect(function()
	for i,v in pairs(CustomWeldSettings:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
	stopfunc = loadstring(codebox.Text)() or function() end
end)

local PresetsHolderSF = Create("ScrollingFrame", {
	BackgroundColor3 = darken(2),
	Size = UDim2.new(1, -12, 0.225/6, 0),
	Position = UDim2.new(0, 0, 0.475/6, 0),
	CanvasSize = UDim2.new(0, 0, 100, 0),
	Parent = CustomWeldCode
})

local PresetsHolder = Create("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(0.95, -12, 0.999, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Parent = PresetsHolderSF
})

Create("UIGridLayout", {
	CellSize = UDim2.new(0.45, 0, 0.002, 0),
	CellPadding = UDim2.new(0.05, 0, 0.00075, 0),
	Parent = PresetsHolder
})

local fileSaving = false
pcall(function()
	makefolder("test")
	writefile("test/test.txt", "hello")
	fileSaving = readfile("test/test.txt") == "hello"
end)

local bannedsymbols = {}
bannedsymbols["\""] = "''"
bannedsymbols["*"] = "\u{2605}"
bannedsymbols[":"] = ";"
bannedsymbols["<"] = "\u{2264}"
bannedsymbols[">"] = "\u{2265}"
bannedsymbols["?"] = "\u{00BF}"
bannedsymbols["\\"] = ""
bannedsymbols["|"] = "I"
bannedsymbols["/"] = "\u{2215}"
local function validate(name)
	for i,v in pairs(bannedsymbols) do
		name = name:gsub(i,v)
	end
	return name
end

local function listfilesfixed(directory)
	if directory == nil then
		directory = ""
	end
	local s,lf = pcall(function()
		return listfiles(directory)
	end)
	if s then
		for i,v in pairs(lf) do
			if string.sub(v,1,2) == "./" then
				v = string.sub(v,3)
			end
		end
	else
		print(lf,"ListFilesFixedError")
	end
	return lf
end
local function getfn(js,first)
	local fn = listfilesfixed("WeldPresets/")
	if fn and typeof(fn) == "table" then
		if not js then
			for i,v in pairs(fn) do
				fn[i] = v:gsub("%..+","")
			end
		end
		if not first then
			for i,v in pairs(fn) do
				fn[i] = v:sub(13)
			end
		end
	else
		fn = {}
	end
	return fn
end

local presetButtons = {}
local CurrentPreset = nil
local function darkenOtherPresetButton() end
local function addPreset(name, code)
	local CurrentPresetButton = Create("TextButton", {
		TextColor3 = mainBorderColor,
		BackgroundColor3 = darken(-1),
		Text = name,
		TextScaled = true,
		Parent = PresetsHolder
	})
	local function onMouseButton1Click()
		darkenOtherPresetButton(CurrentPresetButton)
		darkenOtherPresetButton = function(presetButton)
			if CurrentPresetButton ~= presetButton then
				CurrentPresetButton.BackgroundColor3 = darken(-1)
			end
		end
		CurrentPresetButton.BackgroundColor3 = darken(1)
		codebox.Text = code
		CurrentPreset = name
	end
	CurrentPresetButton.MouseButton1Click:Connect(onMouseButton1Click)
	presetButtons[name] = CurrentPresetButton
	return CurrentPresetButton
end

if fileSaving then
	local files = listfilesfixed()
	if not table.find(files, "WeldPresets/") then
		makefolder("WeldPresets")
	end
	local filenames = getfn()
	local filenamesReal = getfn(true, true)
	for i,v in pairs(filenames) do
		addPreset(v,readfile(filenamesReal[i]))
	end
end

local savePresetButton = Create("TextButton", {
	Size = UDim2.new(0.5, -6, 0.075/6, 0),
	Position = UDim2.new(0.5, -3, 0.325/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	Text = "Save code as a Preset",
	TextScaled = true,
	Parent = CustomWeldCode
})
savePresetButton.MouseButton1Click:Connect(function()
	local NameTextBox = Create("TextBox", {
		Size = UDim2.new(1, 0, 1/8, 0),
		Position = UDim2.new(0.5, 0, 0.8, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		TextColor3 = mainBorderColor,
		BackgroundColor3 = darken(2),
		PlaceholderText = "Input the name for your preset.",
		Text = "",
		TextScaled = true,
		Parent = sgui
	})
	Create("UIAspectRatioConstraint", {
		AspectRatio = 8,
		DominantAxis = Enum.DominantAxis.Height,
		Parent = NameTextBox
	})
	local ConfirmButton = Create("TextButton", {
		Size = UDim2.new(0.3, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1,0),
		Position = UDim2.new(0.9, 0, 1.1, 0),
		TextColor3 = mainBorderColor,
		BackgroundColor3 = Color3.fromRGB(0, 200, 0),
		Text = "Confirm",
		TextScaled = true,
		Parent = NameTextBox
	})
	ConfirmButton.MouseButton1Click:Connect(function()
		NameTextBox:Destroy()
		local name = validate(NameTextBox.Text)..".lua"
		if fileSaving then
			writefile("WeldPresets/"..name, codebox.Text)
		end
		addPreset(validate(NameTextBox.Text), codebox.Text)
	end)
	local CancelButton = Create("TextButton", {
		Size = UDim2.new(0.3, 0, 0.5, 0),
		Position = UDim2.new(0.1, 0, 1.1, 0),
		TextColor3 = mainBorderColor,
		BackgroundColor3 = Color3.fromRGB(200, 0, 0),
		Text = "Cancel",
		TextScaled = true,
		Parent = NameTextBox
	})
	CancelButton.MouseButton1Click:Connect(function()
		NameTextBox:Destroy()
	end)
end)

local deletePresetButton = Create("TextButton", {
	Size = UDim2.new(0.5, -6, 0.075/6, 0),
	Position = UDim2.new(0, 0, 0.325/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	Text = "Delete preset",
	TextScaled = true,
	Parent = CustomWeldCode
})
local bindfunc = Instance.new("BindableFunction")
deletePresetButton.MouseButton1Click:Connect(function()
	if CurrentPreset then
		local filenames = getfn()
		local filenamesReal = getfn(true, true)
		local foundName = table.find(filenames, CurrentPreset)
		if foundName then
			bindfunc.OnInvoke = function(prompt)
				if prompt == "Yes" and CurrentPreset ~= nil then
					delfile(filenamesReal[foundName])
					presetButtons[CurrentPreset]:Destroy()
				end
			end
			StarterGui:SetCore("SendNotification",{Title="Delete Preset?",Text="Are you sure you want to delete the "..CurrentPreset.." preset?",Duration=5,Callback=bindfunc,Button1="Yes",Button2="No"})
		end
	end
end)

Create("TextLabel", {
	Size = UDim2.new(1, -12, 1/6, 0),
	Position = UDim2.new(0, 0, 0.7/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	Text = "functions/varaibles available are: changeWeldOffset(CFrame), changeWeldVelocity(Vector3), changeWeldAnim(number), Create(\"ClassName\", {Properties}), darken(number), CreateWeldInput(parent), CreateUnweldButton(parent), createSlider(\"text\", parent, min, max, default, step, onDrag), getPlayerFromText(text), WeldTo(TargetPart, OverwriteViewPartOnWeld), Unweld, CurrentWeld, WeldOffset, WeldVelocity, WeldAnimID, mainBorderColor, and CustomWeldSettings\nyou can use any lua function since this code will just be loadstrung\nIf the code has a loop it will need to return a \"stop\" function",
	TextScaled = true,
	Parent = CustomWeldCode
})

Create("TextLabel", {
	Size = UDim2.new(1, -12, 0.075/6, 0),
	Position = UDim2.new(0, 0, 0.4/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(3),
	Text = "Presets\nNote: If you don't know anything about lua, its safe to stick to the presets already here, as any code can be run here (including malicious ones)",
	TextScaled = true,
	Parent = CustomWeldCode
})

addPreset("Orbit", [[
local distance = 5
local speed = 5
local rot = 0

CreateUnweldButton(CustomWeldSettings)
CreateWeldInput(CustomWeldSettings)

createSlider("Distance", CustomWeldSettings, 0, 50, 5, nil, function(n)
	distance = n
end)

createSlider("Speed", CustomWeldSettings, 0, 100, 5, nil, function(n)
	speed = n
end)

local loop = true
coroutine.wrap(function()
	while loop do
		task.wait()
		if CurrentWeld then
			rot -= speed
			changeWeldOffset(
				CFrame.Angles(0, math.rad(rot), 0) * CFrame.new(0, 0, distance)
			)
		end
	end
end)()

return function()
	loop = false
end
]])

addPreset("Move Back/Forth", [[
local distance = 5
local speed = 5
local Ok = 0

CreateUnweldButton(CustomWeldSettings)
CreateWeldInput(CustomWeldSettings)

createSlider("Distance", CustomWeldSettings, 0, 50, 3, nil, function(n)
	distance = n
end)

local extradistance = 1
createSlider("Extra Distance (added)", CustomWeldSettings, 0, 50, 1, nil, function(n)
	extradistance = n
end)

createSlider("Speed (divided by 100)", CustomWeldSettings, 0, 100, 20, nil, function(n)
	speed = n/100
end)

local pidiv2 = (math.pi/2)
local loop = true
coroutine.wrap(function()
	while loop do
		task.wait()
		if CurrentWeld then
			Ok += speed
			changeWeldOffset(
				CFrame.new(0, 0, extradistance + (math.asin(math.sin(Ok))) * distance + distance*pidiv2)
			)
		end
	end
end)()

return function()
	loop = false
end
]])

addPreset("Loop between 2 CFrames", [[
local CFrame1 = CFrame.new(0,0,-1)
local CFrame2 = CFrame.new(0,10,-3) * CFrame.Angles(math.rad(270),0,0)
local WaitInterval = 0.5

CreateUnweldButton(CustomWeldSettings)
CreateWeldInput(CustomWeldSettings)

createSlider("Wait Interval", CustomWeldSettings, 0, 5, 0.5, 0.1, function(n)
	WaitInterval = n
end)

Create("TextLabel", {
	Size = UDim2.new(1, -12, 0.075/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(3),
	Text = "CFrame 1 Settings",
	TextScaled = true,
	Parent = CustomWeldSettings
})

createSlider("Weld X (left/right) Value", CustomWeldSettings, -50, 50, 0, nil, function(n)
	local offsetComponents = {CFrame1:GetComponents()}
	offsetComponents[1] = n
	CFrame1 = CFrame.new(table.unpack(offsetComponents))
end)

createSlider("Weld Y (down/up) Value", CustomWeldSettings, -50, 50, 0, nil, function(n)
	local offsetComponents = {CFrame1:GetComponents()}
	offsetComponents[2] = n
	CFrame1 = CFrame.new(table.unpack(offsetComponents))
end)

createSlider("Weld Z (back/forward) Value", CustomWeldSettings, -50, 50, -1, nil, function(n)
	local offsetComponents = {CFrame1:GetComponents()}
	offsetComponents[3] = n
	CFrame1 = CFrame.new(table.unpack(offsetComponents))
end)

local offsetXRot1 = 0
local offsetYRot1 = 0
local offsetZRot1 = 0

createSlider("Weld X Rotation Value", CustomWeldSettings, 0, 360, 0, 5, function(n)
	offsetXRot1 = n
	CFrame1 = CFrame.new(CFrame1.Position) * CFrame.fromOrientation(math.rad(offsetXRot1), math.rad(offsetYRot1), math.rad(offsetZRot1))
end)

createSlider("Weld Y Rotation Value", CustomWeldSettings, 0, 360, 0, 5, function(n)
	offsetYRot1 = n
	CFrame1 = CFrame.new(CFrame1.Position) * CFrame.fromOrientation(math.rad(offsetXRot1), math.rad(offsetYRot1), math.rad(offsetZRot1))
end)

createSlider("Weld Z Rotation Value", CustomWeldSettings, 0, 360, 0, 5, function(n)
	offsetZRot1 = n
	CFrame1 = CFrame.new(CFrame1.Position) * CFrame.fromOrientation(math.rad(offsetXRot1), math.rad(offsetYRot1), math.rad(offsetZRot1))
end)

Create("TextLabel", {
	Size = UDim2.new(1, -12, 0.075/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(3),
	Text = "CFrame 2 Settings",
	TextScaled = true,
	Parent = CustomWeldSettings
})

createSlider("Weld X (left/right) Value", CustomWeldSettings, -50, 50, 0, nil, function(n)
	local offsetComponents = {CFrame2:GetComponents()}
	offsetComponents[1] = n
	CFrame2 = CFrame.new(table.unpack(offsetComponents))
end)

createSlider("Weld Y (down/up) Value", CustomWeldSettings, -50, 50, 10, nil, function(n)
	local offsetComponents = {CFrame2:GetComponents()}
	offsetComponents[2] = n
	CFrame2 = CFrame.new(table.unpack(offsetComponents))
end)

createSlider("Weld Z (back/forward) Value", CustomWeldSettings, -50, 50, -3, nil, function(n)
	local offsetComponents = {CFrame2:GetComponents()}
	offsetComponents[3] = n
	CFrame2 = CFrame.new(table.unpack(offsetComponents))
end)

local offsetXRot2 = 0
local offsetYRot2 = 0
local offsetZRot2 = 0

createSlider("Weld X Rotation Value", CustomWeldSettings, 0, 360, 270, 5, function(n)
	offsetXRot2 = n
	CFrame2 = CFrame.new(CFrame2.Position) * CFrame.fromOrientation(math.rad(offsetXRot2), math.rad(offsetYRot2), math.rad(offsetZRot2))
end)

createSlider("Weld Y Rotation Value", CustomWeldSettings, 0, 360, 0, 5, function(n)
	offsetYRot2 = n
	CFrame2 = CFrame.new(CFrame2.Position) * CFrame.fromOrientation(math.rad(offsetXRot2), math.rad(offsetYRot2), math.rad(offsetZRot2))
end)

createSlider("Weld Z Rotation Value", CustomWeldSettings, 0, 360, 0, 5, function(n)
	offsetZRot2 = n
	CFrame2 = CFrame.new(CFrame2.Position) * CFrame.fromOrientation(math.rad(offsetXRot2), math.rad(offsetYRot2), math.rad(offsetZRot2))
end)


local pidiv2 = (math.pi/2)
local loop = true
local t = 0
coroutine.wrap(function()
	while loop do
		task.wait(WaitInterval)
		t += 1
		if t%2 == 0 then
			changeWeldOffset(CFrame1)
		else
			changeWeldOffset(CFrame2)
		end
	end
end)()

return function()
	loop = false
end
]])

addPreset("Tornado", [[
local distance = 5
local speed = 5
local rot = 0

CreateUnweldButton(CustomWeldSettings)
CreateWeldInput(CustomWeldSettings)

createSlider("Distance", CustomWeldSettings, 0, 50, 5, nil, function(n)
	distance = n
end)

createSlider("Speed", CustomWeldSettings, 0, 100, 5, nil, function(n)
	speed = n
end)

local loop = true
coroutine.wrap(function()
	while loop do
		task.wait()
		if CurrentWeld then
			rot -= speed
			changeWeldOffset(
				CFrame.Angles(0, math.rad(rot), 0) * CFrame.new(0, -distance/2 + -rot%distance, distance)
			)
		end
	end
end)()

return function()
	loop = false
end
]])

addPreset("Weld Tool", [[

local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local StarterGui = game:GetService("StarterGui")
local uis = game:GetService("UserInputService")

StarterGui:SetCore("SendNotification",{Title="Info",Text="You can also Shift+Click to weld.",Duration=5})

local originalWeldOffset = WeldOffset
local UseRegularWeldSettings = false
local URWS = Create("TextButton", {
	Size = UDim2.new(1, -6, 0.075/6, 0),
	TextColor3 = mainBorderColor,
	BackgroundColor3 = darken(1),
	Text = "Use Regular Weld Settings",
	TextScaled = true,
	Parent = CustomWeldSettings
})
local URWSText = URWS.Text
URWS.Text = URWSText..": OFF"
URWS.MouseButton1Click:Connect(function()
	UseRegularWeldSettings = not UseRegularWeldSettings
	if UseRegularWeldSettings then
		URWS.Text = URWSText..": ON"
		changeWeldOffset(originalWeldOffset)
	else
		URWS.Text = URWSText..": OFF"
	end
end)

local rayParams = RaycastParams.new()
rayParams.ExcludeInstances = {game:GetService("Players").LocalPlayer.Character}

local length = 1000
local function raycastMouse()
	local unitRay = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
	local Raycast = workspace:Raycast(unitRay.Origin, unitRay.Direction * length)
	if Raycast then
		return {
			Hit = CFrame.lookAt(Raycast.Position, Raycast.Position + Raycast.Normal),
			Target = Raycast.Instance
		}
	end
	return nil
end


local weldToolTemplate = Instance.new("Tool")
weldToolTemplate.Name = "Weld Tool"
weldToolTemplate.RequiresHandle = false
local SelectionBox = Instance.new("SelectionBox")
SelectionBox.SurfaceTransparency = 0.5
SelectionBox.Parent = game.CoreGui

local function Weld()
	Unweld()
	local Raycast = raycastMouse()
	local weldPart = Raycast.Target
	if not UseRegularWeldSettings then
		changeWeldOffset(
			CFrame.new(Raycast.Hit.Position - weldPart.Position) * (Raycast.Hit - Raycast.Hit.Position)
		)
	end
	WeldTo(weldPart, UseRegularWeldSettings and nil)
end

local function makeNewWeldTool()
	weldTool = weldToolTemplate:Clone()
	weldTool.Parent = game:GetService("Players").LocalPlayer.Backpack
	local equip = false
	local oldTargetFilter
	weldTool.Equipped:Connect(function()
		equip = true
		while equip do
			task.wait()
			SelectionBox.Adornee = mouse.Target
		end
		SelectionBox.Adornee = nil
	end)

	weldTool.Unequipped:Connect(function()
		equip = false
	end)

	weldTool.Activated:Connect(function()
		Weld()
	end)
end
makeNewWeldTool()
local OCA = game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
	makeNewWeldTool()
end)

local shiftEnabled = false
local inputBegan = uis.InputBegan:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and shiftEnabled then
		if processed then
			return
		end
		Weld()
	elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftShift then
		shiftEnabled = true
		while shiftEnabled do
			task.wait()
			SelectionBox.Adornee = mouse.Target
		end
		SelectionBox.Adornee = nil
	end
end)

local inputEnded = uis.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftShift then
		shiftEnabled = false
	end
end)

return function()
	OCA:Disconnect()
	inputBegan:Disconnect()
	inputEnded:Disconnect()
	weldTool:Destroy()
	SelectionBox:Destroy()
	changeWeldOffset(originalWeldOffset)
end
]])



sgui.Destroying:Connect(function()
	for i,v in pairs(conn) do
		v:Disconnect()
	end
	stopfunc()
	Unweld()
end)
