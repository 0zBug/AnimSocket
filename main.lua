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

local Invisible = loadstring(game:HttpGet("https://raw.github.com/0zBug/Invisible/main/main.lua"))()

local AnimSocket = {}

function AnimSocket.Connect(Channel, Secret)
    local Socket = {
        Send = function(self, Message) 
            local Payload = string.format("%s\255%s\255%s", Channel, LocalPlayer.Name, Message)
            Payload = Secret and Invisible.Encode(Payload) or Payload
            
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. math.floor(os.clock()) .. "\255" .. Payload
			
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
            if string.sub(Message, 1, 39) == "Failed to load animation: rbxassetid://" then
                task.wait()

                local Data = string.sub(Message, 40, -1)
                
                if Secret then
                    Data = string.gsub(Data, "%d+\255", "")

                    Data = Invisible.Decode(Data)
                end

                Data = string.split(Data, "\255")

                local Source, Error = pcall(function()
                    Socket.OnMessage:Fire(Players:FindFirstChild(Data[2]), Data[3])
                end)

                if not Source then
                    warn(Error)
                end
            end
        end
	end)
	
    return Socket
end

return AnimSocket
