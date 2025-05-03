-- Compiled with roblox-ts v3.0.0
-- I made this because i didnt code for a few months due to academic stuff
-- Im rusty asf lmao (roblox=ts converted code was never meant to be readable)
-- So dont cry if you are pissed off about the code looking kinda cursed
-- This is not gonna be marked as verified because its just a simple esp
local Workspace = game:GetService("Workspace")
-- VARIABLES
local RunnersFolder = Workspace:WaitForChild("Runners")
local SkinwalkersFolder = RunnersFolder:WaitForChild("Skinwalkers")
-- UTILITIES
local _binding = os
local clock = _binding.clock
local _binding_1 = task
local cancel = _binding_1.cancel
local defer = _binding_1.defer
local delay = _binding_1.delay
local spawn = _binding_1.spawn
local _binding_2 = math
local abs = _binding_2.abs
local atan2 = _binding_2.atan2
local cos = _binding_2.cos
local clamp = _binding_2.clamp
local max = _binding_2.max
local pi = _binding_2.pi
local rad = _binding_2.rad
local sin = _binding_2.sin
local sqrt = _binding_2.sqrt
local EPSILON = 5e-3
local PI, TAU, SEMI, DEG60, DEG45 = pi, 2 * pi, pi / 2, pi / 3, pi / 4
local VECTOR3_2D, VECTOR3_ZERO = Vector3.new(1, 0, 1), Vector3.zero
local WORLD_UP, WORLD_RIGHT, WORLD_FORWARD = Vector3.new(0, 1, 0), Vector3.new(1, 0, 0), Vector3.new(0, 0, 1)
local wrapRad = function(angle)
	return ((angle % TAU) + TAU) % TAU
end
--[[
	*
	 * A simple representation of RBXScriptConnection for custom events.
	 
]]
local Connection
do
	Connection = setmetatable({}, {
		__tostring = function()
			return "Connection"
		end,
	})
	Connection.__index = Connection
	function Connection.new(...)
		local self = setmetatable({}, Connection)
		return self:constructor(...) or self
	end
	function Connection:constructor(disconnect, Connected)
		if Connected == nil then
			Connected = true
		end
		self.disconnect = disconnect
		self.Connected = Connected
	end
	function Connection:Disconnect()
		self.disconnect()
		self.Connected = false
	end
end
--[[
	*
	 * Tracks connections, instances, functions, threads, and objects to be later destroyed.
	 
]]
local Bin
do
	Bin = setmetatable({}, {
		__tostring = function()
			return "Bin"
		end,
	})
	Bin.__index = Bin
	function Bin.new(...)
		local self = setmetatable({}, Bin)
		return self:constructor(...) or self
	end
	function Bin:constructor()
	end
	function Bin:add(item)
		local node = {
			item = item,
		}
		if self.head == nil then
			self.head = node
		end
		if self.tail then
			self.tail.next = node
		end
		self.tail = node
		return item
	end
	function Bin:destroy()
		while self.head do
			local item = self.head.item
			if type(item) == "function" then
				item()
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			elseif type(item) == "thread" then
				task.cancel(item)
			elseif isrenderobj(item) then
				item:Destroy()
			elseif item.destroy ~= nil then
				item:destroy()
			elseif item.Destroy ~= nil then
				item:Destroy()
			elseif item.disconnect ~= nil then
				item:disconnect()
			elseif item.Disconnect ~= nil then
				item:Disconnect()
			elseif item.cancel ~= nil then
				item:cancel()
			end
			self.head = self.head.next
		end
		-- list is now empty, so we can clear the tail
		self.tail = nil
	end
	function Bin:isEmpty()
		return self.head == nil
	end
end
--[[
	*
	 * Waits for a child instance to be added to the given parent object and returns it.
	 
]]
local function expectChild(obj, criteria, timeout)
	if timeout == nil then
		timeout = 1e4
	end
	local _binding_3 = criteria
	local kind = _binding_3[1]
	local name = _binding_3[2]
	local isValid = if name == nil then function(obj)
		return obj:IsA(kind)
	end else function(obj)
		return obj.Name == name and obj:IsA(kind)
	end
	for _, v in obj:GetChildren() do
		if isValid(v) then
			return v
		end
	end
	-- Wait for the child to be added
	local v
	local thread = coroutine.running()
	local c, d = obj.ChildAdded:Connect(function(i)
		if isValid(i) then
			v = i
			spawn(thread)
		end
	end), delay(timeout, function()
		return spawn(thread)
	end)
	coroutine.yield()
	if v then
		cancel(d)
	end
	if c.Connected then
		c:Disconnect()
	end
	return v
end
--[[
	*
	 * Runs for the all child instance that matches the given name and kind.
	 
]]
local function forChildThen(obj, criteria, callback, n)
	if n == nil then
		n = 9e9
	end
	local _binding_3 = criteria
	local kind = _binding_3[1]
	local name = _binding_3[2]
	local isValid = if name == nil then function(obj)
		return obj:IsA(kind)
	end else function(obj)
		return obj.Name == name and obj:IsA(kind)
	end
	for _, v in obj:GetChildren() do
		if isValid(v) then
			spawn(callback, v)
			n -= 1
			if n == 0 then
				return Connection.new(function() end)
			end
		end
	end
	local connection
	connection = obj.ChildAdded:Connect(function(v)
		if isValid(v) then
			spawn(callback, v)
			n -= 1
			if n == 0 then
				connection:Disconnect()
			end
		end
	end)
	return Connection.new(function()
		if connection.Connected then
			connection:Disconnect()
		end
	end)
end
local BaseComponent
do
	BaseComponent = setmetatable({}, {
		__tostring = function()
			return "BaseComponent"
		end,
	})
	BaseComponent.__index = BaseComponent
	function BaseComponent.new(...)
		local self = setmetatable({}, BaseComponent)
		return self:constructor(...) or self
	end
	function BaseComponent:constructor(instance)
		self.instance = instance
		self.bin = Bin.new()
		self.bin:add(instance.Destroying:Connect(function()
			return self:destroy()
		end))
	end
	function BaseComponent:destroy()
		self.bin:destroy()
	end
end
-- COMPONENTS
local NPCComponent
do
	local super = BaseComponent
	NPCComponent = setmetatable({}, {
		__tostring = function()
			return "NPCComponent"
		end,
		__index = super,
	})
	NPCComponent.__index = NPCComponent
	function NPCComponent.new(...)
		local self = setmetatable({}, NPCComponent)
		return self:constructor(...) or self
	end
	function NPCComponent:constructor(instance)
		super.constructor(self, instance)
		local root = expectChild(instance, { "BasePart", "HumanoidRootPart" }, 30)
		if not root then
			error("[NPC Component]: " .. instance.Name .. " does not have a root part!")
		end
		local humanoid = expectChild(instance, { "Humanoid", "Humanoid" }, 30)
		if not humanoid then
			error("[NPC Component]: " .. instance.Name .. " does not have a humanoid!")
		end
		self.root = root
		self.humanoid = humanoid
		self.bin:add(humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			return self:onHealthChanged()
		end))
		-- Initialize:
		spawn(function()
			return self:addHighlight()
		end)
	end
	function NPCComponent:onHealthChanged()
		local health = self.humanoid.Health
		if health == 0 then
			return self:destroy()
		end
	end
	function NPCComponent:addHighlight()
		local Highlight = Instance.new("Highlight")
		Highlight.FillTransparency = 0.7
		Highlight.Parent = self.instance
		-- Bin
		self.bin:add(Highlight)
	end
end
-- CONTROLLERS
local SkilwalkerController = {}
do
	local _container = SkilwalkerController
	local onAdded = function(instance)
		NPCComponent.new(instance)
	end
	local function __init__()
		-- This automatically adds a .ChildAdded connection so i dont have much a hassle
		-- to add extra code and we are done lmao
		forChildThen(SkinwalkersFolder, { "Model" }, function(child)
			onAdded(child)
		end)
	end
	_container.__init__ = __init__
end
-- Initialization
SkilwalkerController.__init__()
