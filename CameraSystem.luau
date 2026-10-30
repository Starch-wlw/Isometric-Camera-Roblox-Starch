-- Made by starch and uhm claude
local UserInputService=game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer= game.Players.LocalPlayer
local Character = script:FindFirstAncestorOfClass("Model")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
local Camera = workspace.CurrentCamera
local PLAYER_CAMERA_ZOOM = 25
local PLAYER_CAMERA_FOV = 70
local FORWARD_DIRECTION= Camera.CFrame.LookVector
local STRAFE_DIRECTION=Camera.CFrame.RightVector
local activeKeys={}
local moveDirection = Vector3.new(0, 0, 0)
local isMobile = UserInputService.TouchEnabled
Humanoid.AutoRotate = false
Camera.CameraType=Enum.CameraType.Scriptable
UserInputService.MouseIconEnabled = true
UserInputService.MouseBehavior=Enum.MouseBehavior.Default

-- this is the wall fade its working perfectly fine 
local function makeAllPartsVisible()
	for _,child in pairs(Character:GetDescendants()) do
		if child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("Part") then
			child.LocalTransparencyModifier = 0
			child.CanQuery = true
			child.CanTouch=true
			child.CanCollide = true
		end
		if child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle")
			if handle then handle.LocalTransparencyModifier=0 end
		end
	end
	if Humanoid then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
	end
end
makeAllPartsVisible()

--strafe, example if u press "w" and "a" it will work i use cam relative for this js like any other game, it prob work with console too?
local function updateDirections()
	FORWARD_DIRECTION=Camera.CFrame.LookVector
	STRAFE_DIRECTION=Camera.CFrame.RightVector
end

local function getHorizontalDirection(vector)
	return Vector3.new(vector.X,0,vector.Z).Unit
end

local function updateMovement()
	if not isMobile then
		local forwardHorizontal = getHorizontalDirection(FORWARD_DIRECTION)
		local strafeHorizontal = getHorizontalDirection(STRAFE_DIRECTION)
		moveDirection = Vector3.new(0,0,0)
		local hasW = activeKeys[Enum.KeyCode.W]
		local hasA=activeKeys[Enum.KeyCode.A]
		local hasS= activeKeys[Enum.KeyCode.S]
		local hasD =activeKeys[Enum.KeyCode.D]
		if hasW then moveDirection=moveDirection+forwardHorizontal end
		if hasS then moveDirection=moveDirection-forwardHorizontal end
		if hasD then moveDirection=moveDirection+strafeHorizontal end
		if hasA then moveDirection=moveDirection-strafeHorizontal end
		if moveDirection.Magnitude>0 then
			moveDirection=moveDirection.Unit
			Humanoid:Move(moveDirection)
		else
			Humanoid:Move(Vector3.new(0,0,0))
		end
	end
	if Humanoid.MoveDirection.Magnitude>0 then
		RootPart.CFrame = CFrame.new(RootPart.Position,RootPart.Position+Humanoid.MoveDirection)
	end
end

RunService.RenderStepped:Connect(function()
	updateDirections()
	updateMovement()
	Camera.FieldOfView=PLAYER_CAMERA_FOV
	if Character then
		local Head = Character:FindFirstChild("Head")
		if Head then
			Camera.CFrame = CFrame.new(Head.Position+Vector3.new(PLAYER_CAMERA_ZOOM,PLAYER_CAMERA_ZOOM,PLAYER_CAMERA_ZOOM),Head.Position)
			game:GetService("SoundService"):SetListener(Enum.ListenerType.ObjectCFrame, Head)
			makeAllPartsVisible()
		end
	end
end)

local function isTyping()
	return UserInputService:GetFocusedTextBox()~=nil
end

UserInputService.InputBegan:Connect(function(Input,gameProcessed)
	if not isMobile then
		updateDirections()
		if gameProcessed or isTyping() then return end
		if Input.KeyCode==Enum.KeyCode.W or Input.KeyCode==Enum.KeyCode.A or Input.KeyCode==Enum.KeyCode.S or Input.KeyCode==Enum.KeyCode.D then
			activeKeys[Input.KeyCode]=true
		end
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if not isMobile then
		if Input.KeyCode==Enum.KeyCode.W or Input.KeyCode==Enum.KeyCode.A or Input.KeyCode==Enum.KeyCode.S or Input.KeyCode==Enum.KeyCode.D then
			activeKeys[Input.KeyCode]=false
		end
	end
end)

UserInputService.TextBoxFocused:Connect(function()
	activeKeys[Enum.KeyCode.W]=false
	activeKeys[Enum.KeyCode.A]=false
	activeKeys[Enum.KeyCode.S]=false
	activeKeys[Enum.KeyCode.D]=false
	Humanoid:Move(Vector3.new(0,0,0))
end)

localPlayer.CharacterAdded:Connect(function(newChar)
	Character=newChar
	RootPart=newChar:WaitForChild("HumanoidRootPart")
	Humanoid=newChar:FindFirstChildWhichIsA("Humanoid")
end)