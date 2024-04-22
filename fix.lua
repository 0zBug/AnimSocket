local Players = game:GetService("Players")
local LogService = game:GetService("LogService")

repeat wait() until Players.LocalPlayer

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(Character)
	Character = Character
	Humanoid = Character:WaitForChild("Humanoid")
end)

local AnimSocket = {}

local function Encode(String)
	local MessageId = {}

	for n = 0, 1 do
		table.insert(MessageId, string.format("%03d", math.random(100, 255)))
	end

	MessageId = table.concat(MessageId)
	
	local Messages = {}

	local Order = 0
	string.gsub(String, "..?.?", function(c)
		local Bytes = {string.byte(c, 1, -1)}

		for Index, Byte in Bytes do
			Bytes[Index] = string.format("%03d", Byte)
		end

		Bytes[2] = Bytes[2] or "000"
		Bytes[3] = Bytes[3] or "000"

		local Message = {MessageId,  string.format("%03d", Order), table.concat(Bytes), (math.floor(#String / 3 - 1) == Order) and 1 or 0}

		table.insert(Messages, table.concat(Message))

		Order = Order + 1
	end)

	return Messages
end

local function Decode(Encoded)
	return string.gsub(Encoded, "...", function(n)
		return string.char(tonumber(n))
	end)
end

local Messages = {}

function AnimSocket.Connect(Channel, Secret)
	local Socket = {
		Send = function(self, Message) 
			local Message = string.format("%s\254%s\254%s", Channel, LocalPlayer.Name, Message)

			for _, Payload in Encode(Message) do
                local Animation = Instance.new("Animation")
                Animation.AnimationId = "rbxassetid://" .. Payload

                local AnimationTrack = Humanoid:LoadAnimation(Animation)
                AnimationTrack:Play()
                AnimationTrack:Stop()

				local MessageId = string.sub(Payload, 1, 6)
                local Order = string.sub(Payload, 7, 9)

				repeat task.wait() until Messages[MessageId] and Messages[MessageId][tonumber(Order) + 1]
            end
		end,
		Close = function(self)
			self.OnClose()
		end,
		OnMessage = {
			Connections = {},
			Connect = function(self, f)
				table.insert(self.Connections, f)
			end,
			Fire = function(self, ...)
				for _,f in pairs(self.Connections) do
					f(...)
				end
			end
		},
		OnClose = function() end
	}

	setreadonly(Socket, true)

	LogService.MessageOut:Connect(function(Message, Type)
		if Type == Enum.MessageType.MessageError then
			if string.sub(Message, 1, 54) == "Failed to load animation - sanitized ID: rbxassetid://" then
				task.wait()
				task.wait()

				local Message = string.sub(Message, 55, -1)

                local MessageId = string.sub(Message, 1, 6)
                local Order = string.sub(Message, 7, 9)
                local Encoded = string.sub(Message, 10, -2)
                local End = tonumber(string.sub(Message, -1, -1))

                Messages[MessageId] = Messages[MessageId] or {End = false}
                Messages[MessageId].End = Messages[MessageId].End or (End == 1 and tonumber(Order) + 1)

                Messages[MessageId][tonumber(Order) + 1] = Decode(Encoded)

                if Messages[MessageId].End and Messages[MessageId].End + 1 == #Messages[MessageId] then
					local Data = string.split(table.concat(Messages[MessageId]), "\254")

					if Data[1] == Channel then
						Socket.OnMessage:Fire(Players:FindFirstChild(Data[2]), Data[3])
					end
                end
			end
		end
	end)

	return Socket
end

return AnimSocket
