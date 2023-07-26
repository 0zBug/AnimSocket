local Players = game:GetService("Players")
local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

repeat wait() until Players.LocalPlayer

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(Character)
	Character = Character
	Humanoid = Character:WaitForChild("Humanoid")
end)

local AnimSocket = {}

function AnimSocket.Connect(Channel)
    local Socket = {
        Send = function(self, Message) 
			local Animation = Instance.new("Animation")
			Animation.AnimationId = string.format("rbxassetid://%s\255%s\255%s\255%s", os.clock(), Channel, LocalPlayer.Name, Message)
			
			local AnimationTrack = Humanoid:LoadAnimation(Animation)
			AnimationTrack:Play()
			AnimationTrack:Stop()
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
			task.wait()
			
			local Data = string.split(string.sub(Message, 40, -1), "\255")
			
			Socket.OnMessage:Fire(Players:FindFirstChild(Data[3]), Data[4])
		end
	end)
	
    return Socket
end

return AnimSocket
